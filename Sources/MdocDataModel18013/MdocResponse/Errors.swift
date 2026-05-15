/*
Copyright (c) 2026 European Commission

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
public typealias ErrorItems = [DataElementIdentifier: ErrorCode]

/// Error codes for each namespace for items that are not returned
public struct Errors: Sendable {

	public let errors: [NameSpace: ErrorItems]
	public subscript(ns: String) -> ErrorItems? { errors[ns] }

	public init(errors: [NameSpace : ErrorItems]) {
		self.errors = errors
	}
}

extension Errors: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(errorMap) = cbor else { throw .invalidCbor("errors") }
        if errorMap.count == 0 { throw .invalidCbor("errors") }
        let namespacePairs = try errorMap.map { (key: CBOR, value: CBOR) throws(MdocValidationError) -> (NameSpace, ErrorItems) in
            guard case .utf8String(let ns) = key else { throw .invalidCbor("errors") }
            guard case .map(let namespaceItemMap) = value else { throw .invalidCbor("errors") }
            let errorItemPairs = try namespaceItemMap.map { (key: CBOR, value: CBOR) throws(MdocValidationError) -> (DataElementIdentifier, ErrorCode) in
                guard case .utf8String(let dataElementIdentifier) = key else { throw .invalidCbor("errors") }
                guard case .unsignedInt(let errorCode) = value else { throw .invalidCbor("errors") }
                return (dataElementIdentifier, errorCode)
            }
            let errorItems = Dictionary(errorItemPairs, uniquingKeysWith: { (first, _) in first })
            if errorItems.count == 0 { throw .invalidCbor("errors") }
            return (ns, errorItems)
        }
        errors = Dictionary(namespacePairs, uniquingKeysWith: { (first, _) in first })
    }
}

extension Errors: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        let namespaceMapEntries = errors.map { (ns: NameSpace, errorItems: ErrorItems) -> (CBOR, CBOR) in
            let namespaceKey = CBOR.utf8String(ns)
            let errorItemEntries = errorItems.map { (dataElementIdentifier: DataElementIdentifier, errorCode: ErrorCode) -> (CBOR, CBOR) in
                (.utf8String(dataElementIdentifier), .unsignedInt(errorCode))
            }
            let namespaceItemsMap = OrderedDictionary(errorItemEntries, uniquingKeysWith: { (key, _) in key })
            return (namespaceKey, .map(namespaceItemsMap))
        }
        let cborMap = OrderedDictionary(namespaceMapEntries, uniquingKeysWith: { (key, _) in key })
        return .map(cborMap)
    }
}

