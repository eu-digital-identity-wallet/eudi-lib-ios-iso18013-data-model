//
//  ValueDigests.swift

import Foundation
import SwiftCBOR

/// Digests of all data elements per namespace
public struct ValueDigests {
	public let valueDigests: [NameSpace: DigestIDs]
	public subscript(ns: NameSpace) -> DigestIDs? {valueDigests[ns] }
	
	public init(valueDigests: [NameSpace : DigestIDs]) {
		self.valueDigests = valueDigests
	}
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

/// Table 21 — Digest algorithm identifiers
public enum DigestAlgorithmKind: String {
	case SHA256 = "SHA-256"
	case SHA384 = "SHA-384"
	case SHA512 = "SHA-512"
}
