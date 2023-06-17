//
//  ValueDigests.swift

import Foundation
import SwiftCBOR

/// Digests of all data elements per namespace
struct ValueDigests {
	let valueDigests: [NameSpace: DigestIDs]
	subscript(ns: NameSpace) -> DigestIDs? {valueDigests[ns] }
}

extension ValueDigests: CBORDecodable {
	init?(cbor: CBOR) {
		guard case let .map(d) = cbor else { return nil }
		var temp = [NameSpace: DigestIDs]()
		for (k,v) in d {
			if case .utf8String(let ns) = k, let dis = DigestIDs(cbor: v) { temp[ns] = dis}
		}
		guard temp.count > 0 else  { return nil }
		valueDigests = temp
	}
}

struct DigestIDs {
	let digestIDs: [DigestID: [UInt8]]
	subscript(digestID: DigestID) -> [UInt8]? {digestIDs[digestID] }
}

extension DigestIDs: CBORDecodable {
	init?(cbor: CBOR) {
		guard case let .map(d) = cbor else { return nil }
		var temp = [DigestID: [UInt8]]()
		for (k,v) in d {
			if case .unsignedInt(let ui) = k, case .byteString(let ud) = v { temp[ui] = ud}
		}
		guard temp.count > 0 else  { return nil }
		digestIDs = temp
	}
}
