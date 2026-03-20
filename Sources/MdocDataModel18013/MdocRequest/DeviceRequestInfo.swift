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

/// DocRequestID: uint
public typealias DocRequestID = UInt

/// DocumentSet: [+ DocRequestID]
public typealias DocumentSet = [DocRequestID]

/// PurposeControllerId: tstr
public typealias PurposeControllerId = String

/// PurposeCode: int
public typealias PurposeCode = Int

/// PurposeHints: { + PurposeControllerId => PurposeCode }
public typealias PurposeHints = OrderedDictionary<PurposeControllerId, PurposeCode>

/// UseCase
public struct UseCase: Sendable {
    public let mandatory: Bool
    public let documentSets: [DocumentSet]
    public let purposeHints: PurposeHints?
    public let extensions: OrderedDictionary<String, CBOR>?
    
    enum Keys: String {
        case mandatory
        case documentSets
        case purposeHints
    }
    
    public init(mandatory: Bool, documentSets: [DocumentSet], purposeHints: PurposeHints? = nil, extensions: OrderedDictionary<String, CBOR>? = nil) {
        self.mandatory = mandatory
        self.documentSets = documentSets
        self.purposeHints = purposeHints
        self.extensions = extensions
    }
}

extension UseCase: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(m) = cbor else { throw .invalidCbor("UseCase") }
        guard let mandatoryValue = m[Keys.mandatory] else { throw .missingField("UseCase", Keys.mandatory.rawValue) }
        guard case let .boolean(b) = mandatoryValue else { throw .invalidCbor("UseCase") }
        mandatory = b
        guard let docSetsValue = m[Keys.documentSets] else { throw .missingField("UseCase", Keys.documentSets.rawValue) }
        guard case let .array(arr) = docSetsValue else { throw .invalidCbor("UseCase") }
        documentSets = try arr.map { cbor  throws(MdocValidationError) in
            guard case let .array(docArray) = cbor else { throw MdocValidationError.invalidCbor("DocumentSet") }
            return try docArray.map { cborItem  throws(MdocValidationError) in
                guard case let .unsignedInt(id) = cborItem else { throw MdocValidationError.invalidCbor("DocRequestID") }
                return UInt(id)
            }
        }
        if let purposeHintsValue = m[Keys.purposeHints] {
            guard case let .map(hintMap) = purposeHintsValue else { throw .invalidCbor("UseCase") }
            var hints = OrderedDictionary<PurposeControllerId, PurposeCode>()
            for (key, value) in hintMap {
                guard case let .utf8String(controllerId) = key else { throw .invalidCbor("UseCase") }
                guard case let .negativeInt(code) = value else {
                    if case let .unsignedInt(code) = value {
                        hints[controllerId] = Int(code)
                    } else { throw .invalidCbor("UseCase") }
                    continue
                }
                hints[controllerId] = -Int(code) - 1
            }
            purposeHints = hints.isEmpty ? nil : hints
        } else {
            purposeHints = nil
        }
        
        // Parse extensions (other keys in the map)
        var exts: OrderedDictionary<String, CBOR>? = nil
        for (key, value) in m {
            if case let .utf8String(k) = key,
               k != Keys.mandatory.rawValue &&
               k != Keys.documentSets.rawValue &&
               k != Keys.purposeHints.rawValue {
                if exts == nil { exts = OrderedDictionary<String, CBOR>() }
                exts?[k] = value
            }
        }
        self.extensions = exts
    }
}

extension UseCase: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var m = OrderedDictionary<CBOR, CBOR>()
        m[.utf8String(Keys.mandatory.rawValue)] = .boolean(mandatory)
        m[.utf8String(Keys.documentSets.rawValue)] = .array(
            documentSets.map { docSet in
                .array(docSet.map { .unsignedInt(UInt64($0)) })
            }
        )
        if let purposeHints {
            var hintsMap = OrderedDictionary<CBOR, CBOR>()
            for (controllerId, code) in purposeHints {
                hintsMap[.utf8String(controllerId)] = code >= 0 ? .unsignedInt(UInt64(code)) : .negativeInt(UInt64(-code - 1))
            }
            m[.utf8String(Keys.purposeHints.rawValue)] = .map(hintsMap)
        }
        if let extensions {
            for (key, value) in extensions {
                m[.utf8String(key)] = value
            }
        }    
        return .map(m)
    }
}

/// DeviceRequestInfo
public struct DeviceRequestInfo: Sendable {
    public let useCases: [UseCase]?
    public let extensions: OrderedDictionary<String, CBOR>?
    
    enum Keys: String {
        case useCases
    }
    
    public init(useCases: [UseCase]? = nil, extensions: OrderedDictionary<String, CBOR>? = nil) {
        self.useCases = useCases
        self.extensions = extensions
    }
}

extension DeviceRequestInfo: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(m) = cbor else { throw .invalidCbor("DeviceRequestInfo") }    
        if let useCasesValue = m[Keys.useCases] {
            guard case let .array(arr) = useCasesValue else { throw .invalidCbor("DeviceRequestInfo") }
            useCases = try arr.map { u throws(MdocValidationError) in try UseCase(cbor: u) }
        } else { useCases = nil }
        // Parse extensions (other keys in the map)
        var exts: OrderedDictionary<String, CBOR>? = nil
        for (key, value) in m {
            if case let .utf8String(k) = key, k != Keys.useCases.rawValue {
                if exts == nil { exts = OrderedDictionary<String, CBOR>() }
                exts?[k] = value
            }
        }
        self.extensions = exts
    }
}

extension DeviceRequestInfo: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var m = OrderedDictionary<CBOR, CBOR>()      
        if let useCases {
            m[.utf8String(Keys.useCases.rawValue)] = .array(
                useCases.map { $0.toCBOR(options: options) }
            )
        }
        if let extensions {
            for (key, value) in extensions {
                m[.utf8String(key)] = value
            }
        }
        return .map(m)
    }
}
