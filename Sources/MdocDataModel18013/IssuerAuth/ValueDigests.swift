//
//  ValueDigests.swift

import Foundation
import SwiftCBOR

/// Digests of all data elements per namespace
public struct ValueDigests {
	public let valueDigests: [NameSpace: DigestIDs]
	public subscript(ns: NameSpace) -> DigestIDs? {valueDigests[ns] }
}

extension ValueDigests: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(d) = cbor else { return nil }
		var temp = [NameSpace: DigestIDs]()
		for (k,v) in d {
			if case .utf8String(let ns) = k, let dis = DigestIDs(cbor: v) { temp[ns] = dis}
		}
		guard temp.count > 0 else  { return nil }
		valueDigests = temp
	}
}

extension ValueDigests: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = [CBOR: CBOR]()
		for (k,v) in valueDigests {
			m[.utf8String(k)] = v.toCBOR(options: CBOROptions())
		}
		return .map(m)
	}
}

