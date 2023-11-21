 /*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
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
	public func toJson() -> [String: Any] {
		CBOR.decodeDictionary(Dictionary(grouping: self, by: { CBOR.utf8String($0.elementIdentifier) }).mapValues { $0.first!.elementValue }, base64: true)
	}
}
