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

/// Returned data elements for each namespace
public struct IssuerNameSpaces {
	
	public let nameSpaces: [NameSpace: [IssuerSignedItem]]
	public subscript(ns: String) -> [IssuerSignedItem]? { nameSpaces[ns] }
	
	public init(nameSpaces: [NameSpace: [IssuerSignedItem]]) {
		self.nameSpaces = nameSpaces
	}
}

extension IssuerNameSpaces: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		var temp = [NameSpace: [IssuerSignedItem]]()
		for (k,v) in m {
			guard case let .utf8String(ns) = k, case let .array(ar) = v else { continue }
			let items = ar.compactMap { c -> IssuerSignedItem? in
				guard case let .tagged(tg, cbs) = c, tg == .encodedCBORDataItem, case let .byteString(bs) = cbs, let isi = IssuerSignedItem(data: bs) else { return nil }
				return isi
			}
			temp[ns] = items
		}
		guard temp.count > 0 else { return nil }
		nameSpaces = temp
	}
}

extension IssuerNameSpaces: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = [CBOR: CBOR]()
		for (n, items) in nameSpaces {
			cbor[.utf8String(n)] = .array(items.map { .tagged(.encodedCBORDataItem, .byteString($0.encode(options: options))) })
		}
		return .map(cbor)
	}
}

extension Array where Element == IssuerSignedItem {
	public func findItem(name: String) -> IssuerSignedItem? { first(where: { $0.elementIdentifier == name} ) }
	public func findMap(name: String) -> [CBOR:CBOR]? { first(where: { $0.elementIdentifier == name} )?.getTypedValue() }
	public func findArray(name: String) -> [CBOR]? { first(where: { $0.elementIdentifier == name} )?.getTypedValue() }
	public func toJson(base64: Bool = false) -> [String: Any] {
		CBOR.decodeDictionary(Dictionary(grouping: self, by: { CBOR.utf8String($0.elementIdentifier) }).mapValues { $0.first!.elementValue }, base64: base64)
	}
}
