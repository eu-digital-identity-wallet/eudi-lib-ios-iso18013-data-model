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

//  ValidityInfo.swift
import Foundation
import SwiftCBOR
import OrderedCollections

/// The `ValidityInfo` structure contains information related to the validity of the MSO and its signature
public struct ValidityInfo {
	// string tdate from CBOR
	public let signed: String
	public let validFrom: String
	public let validUntil: String
	public let expectedUpdate: String?
	
	enum Keys: String {
		case signed
		case validFrom
		case validUntil
		case expectedUpdate
	}
	public init(signed: String, validFrom: String, validUntil: String, expectedUpdate: String? = nil) {
		self.signed = signed
		self.validFrom = validFrom
		self.validUntil = validUntil
		self.expectedUpdate = expectedUpdate
	}
}

extension ValidityInfo: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(v) = cbor else { return nil }
		guard case .tagged(let t, let cs) = v[Keys.signed], t == .standardDateTimeString, case let .utf8String(s) = cs else { return nil }
		signed = s
		guard case .tagged(let t, let cvf) = v[Keys.validFrom], t == .standardDateTimeString, case let .utf8String(vf) = cvf else { return nil }
		validFrom = vf
		guard case .tagged(let t, let cvu) = v[Keys.validUntil], t == .standardDateTimeString, case let .utf8String(vu) = cvu else { return nil }
		validUntil = vu
		if case .tagged(let t, let ceu) = v[Keys.expectedUpdate], t == .standardDateTimeString, case let .utf8String(eu) = ceu { expectedUpdate = eu } else { expectedUpdate = nil }
	}
}

extension ValidityInfo: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = OrderedDictionary<CBOR, CBOR>()
		m[.utf8String(Keys.signed.rawValue)] = .tagged(.standardDateTimeString, .utf8String(signed))
		m[.utf8String(Keys.validFrom.rawValue)] = .tagged(.standardDateTimeString, .utf8String(validFrom))
		m[.utf8String(Keys.validUntil.rawValue)] = .tagged(.standardDateTimeString, .utf8String(validUntil))
		if let expectedUpdate { m[.utf8String(Keys.expectedUpdate.rawValue)] = .tagged(.standardDateTimeString, .utf8String(expectedUpdate)) }
		return .map(m)
	}
}

