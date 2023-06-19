import Foundation
import SwiftCBOR

struct ReaderAuth {
    let coseSign1: Cose
	let iaca: SecCertificate
}

extension ReaderAuth: CBORDecodable {
    init?(cbor: CBOR) {
        // The signature is contained in an untagged COSE_Sign1 structure as defined in RFC 8152 and identified
        guard let cose = Cose(type: .sign1, cbor: cbor) else { return nil }
        coseSign1 = cose
		guard let ch = cose.unprotectedHeader?.rawHeader, case let .map(mch) = ch else { return nil }
		guard case let .byteString(biaca) = mch[.unsignedInt(33)] else { return nil }
		guard let sc = SecCertificateCreateWithData(nil, Data(biaca) as CFData) else { return nil }
		iaca = sc
    }
}

extension ReaderAuth: CBOREncodable {
	func toCBOR(options: CBOROptions) -> CBOR {
        coseSign1.toCBOR(options: options)
    }
}