//
//  ValidityInfo.swift
import Foundation
import SwiftCBOR

/// The `ValidityInfo` structure contains information related to the validity of the MSO and its signature
struct ValidityInfo {
	// string tdate from CBOR
	let signed: String
	let validFrom: String
	let validUntil: String
	let expectedUpdate: String?
	
	enum Keys: String {
		case signed
		case validFrom
		case validUntil
		case expectedUpdate
	}
}

extension ValidityInfo: CBORDecodable {
	init?(cbor: CBOR) {
		guard case let .map(v) = cbor else { return nil }
		guard case .tagged(_, let cs) = v[Keys.signed], case let .utf8String(s) = cs else { return nil }
		signed = s
		guard case .tagged(_, let cvf) = v[Keys.validFrom], case let .utf8String(vf) = cvf else { return nil }
		validFrom = vf
		guard case .tagged(_, let cvu) = v[Keys.validUntil], case let .utf8String(vu) = cvu else { return nil }
		validUntil = vu
		if case .tagged(_, let ceu) = v[Keys.expectedUpdate], case let .utf8String(eu) = ceu { expectedUpdate = eu } else { expectedUpdate = nil }
	}
}

