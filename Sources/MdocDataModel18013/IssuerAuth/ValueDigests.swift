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
