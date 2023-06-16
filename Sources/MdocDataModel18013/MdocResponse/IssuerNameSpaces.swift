//
//  IssuerNameSpaces.swift

import Foundation
import SwiftCBOR

struct IssuerNameSpaces {
	let issuerNameSpaces: [NameSpace: [IssuerSignedItem]]
	subscript(ns: String) -> [IssuerSignedItem]? { issuerNameSpaces[ns] }
}

extension IssuerNameSpaces: CBORDecodable {
	init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		var temp = [NameSpace: [IssuerSignedItem]]()
		for (k,v) in m {
			guard case let .utf8String(ns) = k, case let .array(ar) = v else { continue }
			let items = ar.compactMap { c -> IssuerSignedItem? in
				guard case let .tagged(_, cbs) = c, case let .byteString(bs) = cbs, let isi = IssuerSignedItem(data: bs) else { return nil }
				return isi
			}
			temp[ns] = items
		}
		guard temp.count > 0 else { return nil }
		issuerNameSpaces = temp
	}
}
