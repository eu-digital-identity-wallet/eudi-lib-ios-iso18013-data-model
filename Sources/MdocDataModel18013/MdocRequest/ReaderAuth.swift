import Foundation
import SwiftCBOR

/// Reader authentication structure encoded as Cose Sign1
struct ReaderAuth {
	/// encoded data
    let coseSign1: Cose
	/// one or more certificates
	let iaca: [[UInt8]] 
}

extension ReaderAuth: CBORDecodable {
    init?(cbor: CBOR) {
        // The signature is contained in an untagged COSE_Sign1 structure as defined in RFC 8152 and identified
        guard let cose = Cose(type: .sign1, cbor: cbor) else { return nil }
        coseSign1 = cose
	    guard let ch = cose.unprotectedHeader?.rawHeader, case let .map(mch) = ch  else { return nil }
		if case let .byteString(bs) = mch[.unsignedInt(33)] { iaca = [bs] }
		else if case let .array(a) = mch[.unsignedInt(33)] { iaca = a.compactMap { if case let .byteString(bs) = $0 { return bs } else { return nil } } }
		else { return nil }
    }
}

extension ReaderAuth: CBOREncodable {
	func toCBOR(options: CBOROptions) -> CBOR {
        coseSign1.toCBOR(options: options)
    }
}
