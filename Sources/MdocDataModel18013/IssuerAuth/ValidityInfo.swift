/*
Copyright (c) 2026 European Commission

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
public struct ValidityInfo: Sendable {
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
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(validityInfoMap) = cbor else { throw .invalidCbor("validity info") }

		guard case .tagged(let signedTag, let signedCbor) = validityInfoMap[Keys.signed],
			  signedTag == .standardDateTimeString,
			  case let .utf8String(signedValue) = signedCbor
		else { throw .missingField("ValidityInfo", Keys.signed.rawValue) }
		guard !signedValue.contains(".") else { throw .invalidDateTimeFormat("ValidityInfo", Keys.signed.rawValue) }
		signed = signedValue

		guard case .tagged(let validFromTag, let validFromCbor) = validityInfoMap[Keys.validFrom],
			  validFromTag == .standardDateTimeString,
			  case let .utf8String(validFromValue) = validFromCbor
		else { throw .missingField("ValidityInfo", Keys.validFrom.rawValue) }
		guard !validFromValue.contains(".") else { throw .invalidDateTimeFormat("ValidityInfo", Keys.validFrom.rawValue) }
		validFrom = validFromValue

		guard case .tagged(let validUntilTag, let validUntilCbor) = validityInfoMap[Keys.validUntil],
			  validUntilTag == .standardDateTimeString,
			  case let .utf8String(validUntilValue) = validUntilCbor
		else { throw .missingField("ValidityInfo", Keys.validUntil.rawValue) }
		guard !validUntilValue.contains(".") else { throw .invalidDateTimeFormat("ValidityInfo", Keys.validUntil.rawValue) }
		validUntil = validUntilValue

		if case .tagged(let expectedUpdateTag, let expectedUpdateCbor) = validityInfoMap[Keys.expectedUpdate],
		   expectedUpdateTag == .standardDateTimeString,
		   case let .utf8String(expectedUpdateValue) = expectedUpdateCbor
		{
			guard !expectedUpdateValue.contains(".") else { throw .invalidDateTimeFormat("ValidityInfo", Keys.expectedUpdate.rawValue) }
			expectedUpdate = expectedUpdateValue
		} else { expectedUpdate = nil }
	}
}

extension ValidityInfo: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var map = OrderedDictionary<CBOR, CBOR>()
		map[.utf8String(Keys.signed.rawValue)] = .tagged(.standardDateTimeString, .utf8String(signed))
		map[.utf8String(Keys.validFrom.rawValue)] = .tagged(.standardDateTimeString, .utf8String(validFrom))
		map[.utf8String(Keys.validUntil.rawValue)] = .tagged(.standardDateTimeString, .utf8String(validUntil))
		if let expectedUpdate {
			let expectedUpdateTag = CBOR.tagged(.standardDateTimeString, .utf8String(expectedUpdate))
			map[.utf8String(Keys.expectedUpdate.rawValue)] = expectedUpdateTag
		}
		return .map(map)
	}
}

