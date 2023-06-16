//
//  IssuerAuth.swift

import Foundation
import SwiftCBOR

struct IssuerAuth {
	let mso: MobileSecurityObject
	let iaca: SecCertificate
}

extension IssuerAuth: CBORDecodable {
	init?(cbor: CBOR) {
		guard let cose = Cose(cbor: cbor) else { return nil}
		guard case let .byteString(bs) = cose.payload, let m = MobileSecurityObject(data: bs) else { return nil}
		//guard let m = MobileSecurityObject(cbor: cose.payload) else { return nil}
		mso = m
		guard let ch = cose.unprotectedHeader?.rawHeader, case let .map(mch) = ch else { return nil }
		guard case let .byteString(biaca) = mch[.unsignedInt(33)] else { return nil }
		guard let sc = SecCertificateCreateWithData(nil, Data(biaca) as CFData) else { return nil }
		iaca = sc
	}
}


