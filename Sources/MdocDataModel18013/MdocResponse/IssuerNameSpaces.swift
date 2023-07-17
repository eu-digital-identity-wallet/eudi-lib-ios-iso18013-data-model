//
//  IssuerNameSpaces.swift

import Foundation
import SwiftCBOR

/// Returned data elements for each namespace
public struct IssuerNameSpaces {
	public let issuerNameSpaces: [NameSpace: [IssuerSignedItem]]
	public subscript(ns: String) -> [IssuerSignedItem]? { issuerNameSpaces[ns] }
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
		issuerNameSpaces = temp
	}
}

extension IssuerNameSpaces: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = [CBOR: CBOR]()
		for (n, items) in issuerNameSpaces {
			cbor[.utf8String(n)] = .array(items.map { .tagged(.encodedCBORDataItem, .byteString($0.encode(options: options))) })
		}
		return .map(cbor)
	}
}

extension Array where Element == IssuerSignedItem {
	public func findItem(name: String) -> IssuerSignedItem? { first(where: { $0.elementIdentifier == name} ) }
}
