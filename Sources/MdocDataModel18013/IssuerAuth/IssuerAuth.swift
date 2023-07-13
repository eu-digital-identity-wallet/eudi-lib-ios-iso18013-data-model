//
//  IssuerAuth.swift

import Foundation
import SwiftCBOR

struct IssuerAuth {
	let mso: MobileSecurityObject
	/// one or more certificates
	let iaca: [[UInt8]] 
}

/// Contains the mobile security object (MSO) for issuer data authentication
///
/// Encoded as `Cose` ( COSE Sign1). The payload is the MSO
extension IssuerAuth: CBORDecodable {
	init?(cbor: CBOR) {
		guard let cose = Cose(type: .sign1, cbor: cbor) else { return nil}
		guard case let .byteString(bs) = cose.payload, let m = MobileSecurityObject(data: bs) else { return nil}
		mso = m
		guard let ch = cose.unprotectedHeader?.rawHeader, case let .map(mch) = ch  else { return nil }
		if case let .byteString(bs) = mch[.unsignedInt(33)] { iaca = [bs] }
		else if case let .array(a) = mch[.unsignedInt(33)] { iaca = a.compactMap { if case let .byteString(bs) = $0 { return bs } else { return nil } } }
		else { return nil }
	}
}


