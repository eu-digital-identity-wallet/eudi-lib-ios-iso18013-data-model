/*
Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation
import SwiftCBOR
import OrderedCollections

/// IssuerIdentifier
public typealias IssuerIdentifier = [UInt8]

/// UniqueDocSetRequired flag
public typealias UniqueDocSetRequired = Bool

/// MaximumResponseSize
public typealias MaximumResponseSize = UInt

/// ElementReference: [NameSpace, DataElementIdentifier]
public struct ElementReference: Sendable, Equatable {
    public let nameSpace: NameSpace
    public let dataElementIdentifier: DataElementIdentifier
    
    public init(nameSpace: NameSpace, dataElementIdentifier: DataElementIdentifier) {
        self.nameSpace = nameSpace
        self.dataElementIdentifier = dataElementIdentifier
    }
}

extension ElementReference: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .array(arr) = cbor, arr.count == 2 else { throw .invalidCbor("ElementReference") }
        guard case let .utf8String(ns) = arr[0] else { throw .invalidCbor("ElementReference") }
        guard case let .utf8String(dei) = arr[1] else { throw .invalidCbor("ElementReference") }
        self.nameSpace = ns
        self.dataElementIdentifier = dei
    }
}

extension ElementReference: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        return .array([
            .utf8String(nameSpace),
            .utf8String(dataElementIdentifier)
        ])
    }
}

/// AlternativeElementSet: [+ ElementReference]
public typealias AlternativeElementSet = [ElementReference]

/// AlternativeDataElementsSet
public struct AlternativeDataElementsSet: Sendable {
    public let requestedElement: ElementReference
    public let alternativeElementSets: [AlternativeElementSet]
    public let extensions: OrderedDictionary<String, CBOR>?
    
    enum Keys: String {
        case requestedElement
        case alternativeElementSets
    }
    
    public init(requestedElement: ElementReference, alternativeElementSets: [AlternativeElementSet], extensions: OrderedDictionary<String, CBOR>? = nil) {
        self.requestedElement = requestedElement
        self.alternativeElementSets = alternativeElementSets
        self.extensions = extensions
    }
}

extension AlternativeDataElementsSet: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(m) = cbor else { throw .invalidCbor("AlternativeDataElementsSet") }
        guard let reqElem = m[Keys.requestedElement] else { throw .missingField("AlternativeDataElementsSet", Keys.requestedElement.rawValue) }
        requestedElement = try ElementReference(cbor: reqElem)
        
        guard let altElemSets = m[Keys.alternativeElementSets] else { throw .missingField("AlternativeDataElementsSet", Keys.alternativeElementSets.rawValue) }
        guard case let .array(arr) = altElemSets else { throw .invalidCbor("AlternativeDataElementsSet") }
        alternativeElementSets = try arr.map { cborSet throws(MdocValidationError) in
            guard case let .array(setArr) = cborSet else { throw MdocValidationError.invalidCbor("AlternativeElementSet") }
            return try setArr.map { e throws(MdocValidationError) in try ElementReference(cbor: e) }
        }
        
        // Parse extensions (other keys in the map)
        var exts: OrderedDictionary<String, CBOR>? = nil
        for (key, value) in m {
            if case let .utf8String(k) = key, k != Keys.requestedElement.rawValue && k != Keys.alternativeElementSets.rawValue {
                if exts == nil { exts = OrderedDictionary<String, CBOR>() }
                exts?[k] = value
            }
        }
        self.extensions = exts
    }
}

extension AlternativeDataElementsSet: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var m = OrderedDictionary<CBOR, CBOR>()
        m[.utf8String(Keys.requestedElement.rawValue)] = requestedElement.toCBOR(options: options)
        m[.utf8String(Keys.alternativeElementSets.rawValue)] = .array(
            alternativeElementSets.map { set in
                .array(set.map { $0.toCBOR(options: options) })
            }
        )
        if let extensions {
            for (key, value) in extensions {
                m[.utf8String(key)] = value
            }
        }
        return .map(m)
    }
}

/// DocRequestInfo
public struct DocRequestInfo: Sendable {
    public let alternativeDataElements: [AlternativeDataElementsSet]?
    public let issuerIdentifiers: [IssuerIdentifier]?
    public let uniqueDocSetRequired: UniqueDocSetRequired?
    public let maximumResponseSize: MaximumResponseSize?
    public let zkRequest: ZkRequest?
    public let extensions: OrderedDictionary<String, CBOR>?
    
    enum Keys: String {
        case alternativeDataElements
        case issuerIdentifiers
        case uniqueDocSetRequired
        case maximumResponseSize
        case zkRequest
    }
    
    public init(alternativeDataElements: [AlternativeDataElementsSet]? = nil, issuerIdentifiers: [IssuerIdentifier]? = nil, uniqueDocSetRequired: UniqueDocSetRequired? = nil, maximumResponseSize: MaximumResponseSize? = nil, zkRequest: ZkRequest? = nil, extensions: OrderedDictionary<String, CBOR>? = nil) {
        self.alternativeDataElements = alternativeDataElements
        self.issuerIdentifiers = issuerIdentifiers
        self.uniqueDocSetRequired = uniqueDocSetRequired
        self.maximumResponseSize = maximumResponseSize
        self.zkRequest = zkRequest
        self.extensions = extensions
    }
}

extension DocRequestInfo: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(m) = cbor else { throw .invalidCbor("DocRequestInfo") }
        // parse alternativeDataElements
        if let altData = m[Keys.alternativeDataElements] {
            guard case let .array(arr) = altData else { throw .invalidCbor("DocRequestInfo") }
            alternativeDataElements = try arr.map { ae throws(MdocValidationError) in try AlternativeDataElementsSet(cbor: ae) }
        } else { alternativeDataElements = nil}
        // parse issuerIdentifiers
        if let issuerIds = m[Keys.issuerIdentifiers] {
            guard case let .array(arr) = issuerIds else { throw .invalidCbor("DocRequestInfo") }
            issuerIdentifiers = try arr.map { cbor throws(MdocValidationError) in
                guard case let .byteString(bs) = cbor else { throw MdocValidationError.invalidCbor("DocRequestInfo") }
                return bs
            }
        } else { issuerIdentifiers = nil }
        // parse uniqueDocSetRequired
        if let uniqueDoc = m[Keys.uniqueDocSetRequired] {
            guard case let .boolean(b) = uniqueDoc else { throw .invalidCbor("DocRequestInfo") }
            uniqueDocSetRequired = b
        } else { uniqueDocSetRequired = nil }
        // parse maximumResponseSize
        if let maxResponse = m[Keys.maximumResponseSize] {
            guard case let .unsignedInt(size) = maxResponse else { throw .invalidCbor("DocRequestInfo") }
            maximumResponseSize = UInt(size)
        } else { maximumResponseSize = nil }
        // parse zkRequest
        if let zkReq = m[Keys.zkRequest] {
            zkRequest = try ZkRequest(cbor: zkReq)
        } else { zkRequest = nil }        
        // Parse extensions (other keys in the map)
        var exts: OrderedDictionary<String, CBOR>? = nil
        for (key, value) in m {
            if case let .utf8String(k) = key,
               k != Keys.alternativeDataElements.rawValue &&
               k != Keys.issuerIdentifiers.rawValue &&
               k != Keys.uniqueDocSetRequired.rawValue &&
               k != Keys.maximumResponseSize.rawValue &&
               k != Keys.zkRequest.rawValue {
                if exts == nil { exts = OrderedDictionary<String, CBOR>() }
                exts?[k] = value
            }
        }
        self.extensions = exts
    }
}

extension DocRequestInfo: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var m = OrderedDictionary<CBOR, CBOR>()
        // encode alternativeDataElements
        if let altData = alternativeDataElements {
            m[.utf8String(Keys.alternativeDataElements.rawValue)] = .array(
                altData.map { $0.toCBOR(options: options) }
            )
        }
        // encode issuerIdentifiers
        if let issuerIds = issuerIdentifiers {
            m[.utf8String(Keys.issuerIdentifiers.rawValue)] = .array(
                issuerIds.map { .byteString($0) }
            )
        }
        // encode uniqueDocSetRequired
        if let uniqueDoc = uniqueDocSetRequired {
            m[.utf8String(Keys.uniqueDocSetRequired.rawValue)] = .boolean(uniqueDoc)
        }
        // encode maximumResponseSize
        if let maxResponse = maximumResponseSize {
            m[.utf8String(Keys.maximumResponseSize.rawValue)] = .unsignedInt(UInt64(maxResponse))
        }
        // encode zkRequest
        if let zkReq = zkRequest {
            m[.utf8String(Keys.zkRequest.rawValue)] = zkReq.toCBOR(options: options)
        }
        // encode extensions
        if let extensions {
            for (key, value) in extensions {
                m[.utf8String(key)] = value
            }
        }
        return .map(m)
    }
}
