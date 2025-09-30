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

//  ValueDigests.swift

import Foundation
import SwiftCBOR
import OrderedCollections

/// Digests of all data elements per namespace
public struct ValueDigests: Sendable {
	public let valueDigests: [NameSpace: DigestIDs]
	public subscript(ns: NameSpace) -> DigestIDs? {valueDigests[ns] }

	public init(valueDigests: [NameSpace : DigestIDs]) {
		self.valueDigests = valueDigests
	}
}

extension ValueDigests: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(d) = cbor else { throw .invalidCbor("value digests") }
		var temp = [NameSpace: DigestIDs]()
		for (k,v) in d {
			if case .utf8String(let ns) = k  { temp[ns] = try DigestIDs(cbor: v)}
		}
		valueDigests = temp
	}
}

extension ValueDigests: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = OrderedDictionary<CBOR, CBOR>()
		for (k,v) in valueDigests {
			m[.utf8String(k)] = v.toCBOR(options: CBOROptions())
		}
		return .map(m)
	}
}

/// Table 21 — Digest algorithm identifiers
public enum DigestAlgorithmKind: String, Sendable {
	case SHA256 = "SHA-256"
	case SHA384 = "SHA-384"
	case SHA512 = "SHA-512"
}
