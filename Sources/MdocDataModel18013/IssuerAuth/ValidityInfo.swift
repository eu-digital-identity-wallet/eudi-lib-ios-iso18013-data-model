//
//  ValidityInfo.swift
import Foundation
import SwiftCBOR

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
		var m = [CBOR: CBOR]()
		m[.utf8String(Keys.signed.rawValue)] = .tagged(.standardDateTimeString, .utf8String(signed))
		m[.utf8String(Keys.validFrom.rawValue)] = .tagged(.standardDateTimeString, .utf8String(validFrom))
		m[.utf8String(Keys.validUntil.rawValue)] = .tagged(.standardDateTimeString, .utf8String(validUntil))
		if let expectedUpdate { m[.utf8String(Keys.expectedUpdate.rawValue)] = .tagged(.standardDateTimeString, .utf8String(expectedUpdate)) }
		return .map(m)
	}
}

