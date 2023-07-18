//
//  IssuerAuth.swift

import Foundation
import SwiftCBOR

public struct IssuerAuth {
	public let mso: MobileSecurityObject
	let msoRawData: [UInt8]
	/// one or more certificates
	public let verifyAlgorithm: Cose.VerifyAlgorithm
	public let signature: Data
	public let iaca: [[UInt8]]
	
	public init(mso: MobileSecurityObject, msoRawData: [UInt8], verifyAlgorithm: Cose.VerifyAlgorithm, signature: Data, iaca: [[UInt8]]) {
		self.mso = mso
		self.msoRawData = msoRawData
		self.verifyAlgorithm = verifyAlgorithm
		self.signature = signature
		self.iaca = iaca
	}
}

/// Contains the mobile security object (MSO) for issuer data authentication
///
/// Encoded as `Cose` ( COSE Sign1). The payload is the MSO
extension IssuerAuth: CBORDecodable {

	public init?(cbor: CBOR) {
		guard let cose = Cose(type: .sign1, cbor: cbor) else { return nil}
		guard case let .byteString(bs) = cose.payload, let m = MobileSecurityObject(data: bs), let va = cose.verifyAlgorithm else { return nil}
		mso = m; msoRawData = bs; verifyAlgorithm = va; signature = cose.signature
		guard let ch = cose.unprotectedHeader?.rawHeader, case let .map(mch) = ch  else { return nil }
		if case let .byteString(bs) = mch[.unsignedInt(33)] { iaca = [bs] }
		else if case let .array(a) = mch[.unsignedInt(33)] { iaca = a.compactMap { if case let .byteString(bs) = $0 { return bs } else { return nil } } }
		else { return nil }
	}
}

extension IssuerAuth: CBOREncodable {
	public func toCBOR(options: SwiftCBOR.CBOROptions) -> SwiftCBOR.CBOR {
		let unprotectedHeaderCbor = CBOR.map([.unsignedInt(33): iaca.count == 1 ? CBOR.byteString(iaca[0]) : CBOR.array(iaca.map { CBOR.byteString($0) })])
		let cose = Cose(type: .sign1, algorithm: verifyAlgorithm.rawValue, payloadData: Data(msoRawData), unprotectedHeaderCbor:  unprotectedHeaderCbor, signature: signature)
		return cose.toCBOR(options: options)
	}
}


