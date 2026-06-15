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

/// Returned data elements for each namespace
public struct IssuerNameSpaces: Sendable {

	public let nameSpaces: [NameSpace: [IssuerSignedItem]]
	public subscript(ns: String) -> [IssuerSignedItem]? { nameSpaces[ns] }

	public init(nameSpaces: [NameSpace: [IssuerSignedItem]]) {
		self.nameSpaces = nameSpaces
	}
}

extension IssuerNameSpaces: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(m) = cbor else { throw .invalidCbor("issuer namespaces") }
		var temp = [NameSpace: [IssuerSignedItem]]()
		for (k,v) in m {
			guard case let .utf8String(ns) = k, case let .array(ar) = v else { continue }
			guard !ar.isEmpty else { throw .invalidCbor("issuer namespace '\(ns)' empty array") }
			let items = try ar.map { c throws(MdocValidationError) -> IssuerSignedItem in
				guard case let .tagged(tg, cbs) = c, tg == .encodedCBORDataItem, case let .byteString(bs) = cbs else {
                    throw .invalidCbor("issuer signed item '\(k)'")
                }
				return try IssuerSignedItem(data: bs)
			}
			temp[ns] = items
		}
		guard temp.count > 0 else { throw .invalidCbor("document") }
		nameSpaces = temp
	}
}

extension IssuerNameSpaces: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = OrderedDictionary<CBOR, CBOR>()
		for (n, items) in nameSpaces {
			let encodedItems = items.map { item in
				CBOR.tagged(.encodedCBORDataItem, .byteString(item.encode(options: options)))
			}
			cbor[.utf8String(n)] = .array(encodedItems)
		}
		return .map(cbor)
	}
}

extension Array where Element == IssuerSignedItem {
	public func findItem(name: String) -> IssuerSignedItem? { first(where: { $0.elementIdentifier == name} ) }
	public func findMap(name: String) -> OrderedDictionary<CBOR, CBOR>? { first(where: { $0.elementIdentifier == name} )?.getTypedValue() }
	public func findArray(name: String) -> [CBOR]? { first(where: { $0.elementIdentifier == name} )?.getTypedValue() }
	public func toJson(base64: Bool = false) -> OrderedDictionary<String, Any> {
		let groupedItems = OrderedDictionary(grouping: self, by: { CBOR.utf8String($0.elementIdentifier) })
		let firstValuesByIdentifier = groupedItems.mapValues { $0.first!.elementValue }
		return CBOR.decodeDictionary(firstValuesByIdentifier, base64: base64)
	}
}
