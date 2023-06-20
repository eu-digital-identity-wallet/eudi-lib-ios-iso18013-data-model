//
//  Cose.swift

import Foundation
import SwiftCBOR
import Security

extension Cose {
	/// COSE Message Identification
	enum CoseType : String {
		/// COSE Single Signer Data Object
		/// Only one signature is applied on the message payload
		case sign1 = "Signature1"
		case mac0 = "MAC0"
		/// Identtifies Cose Message Type from input data
		static func from(data: Data) -> CoseType? {
			guard let cose = try? CBORDecoder(input: data.bytes).decodeItem()?.asCose() else {
				return nil
			}
			
			switch cose.0 {
			case .coseSign1Item:
				return .sign1
			case .coseMac0Item:
				return .mac0
			default:
				return nil
			}
		}
	}
	
	/// ECDSA Algorithm Values defined in
	///
	/// Table1 in rfc/rfc8152#section-16.2
	enum VerifyAlgorithm: UInt64 {
		case es256 = 6 //-7 ECDSA w/ SHA-256
		case es384 = 34 //-35 ECDSA w/ SHA-384
		case es512 = 35//-36 ECDSA w/ SHA-512
		case ps256 = 36 //-37
	}
	
	/// MAC Algorithm Values
	///
	/// Table 7  in rfc/rfc8152#section-16.2
	enum MacAlgorithm: UInt64 {
		case hmac256 = 5 //HMAC w/ SHA-256
		case hmac384 = 6 //HMAC w/ SHA-384
		case hmac512 = 7 //HMAC w/ SHA-512
	}
}

extension Cose {
	struct CoseHeader {
		enum Headers : Int {
			case keyId = 4
			case algorithm = 1
		}
		
		
		let rawHeader : CBOR?
		let keyId : [UInt8]?
		let algorithm : UInt64?
		
		// MARK: - Initializers
		
		init?(fromBytestring cbor: CBOR){
			guard let cborMap = cbor.decodeBytestring()?.asMap(),
				  let alg = cborMap[Headers.algorithm]?.asUInt64() else {
				self.init(alg: nil, keyId: nil, rawHeader: cbor)
				return
			}
			self.init(alg: alg, keyId: cborMap[Headers.keyId]?.asBytes(), rawHeader: cbor)
		}
		
		// MARK: - Private
		private init(alg: UInt64?, keyId: [UInt8]?, rawHeader : CBOR? = nil){
			self.algorithm = alg
			self.keyId = keyId
			self.rawHeader = rawHeader
		}
	}
}

 /// Struct which describes  a representation for cryptographic keys;  how to create and process signatures, message authentication codes, and  encryption using Concise Binary Object Representation (CBOR) or serialization.
struct Cose {
	let type: CoseType
	let protectedHeader : CoseHeader
	let unprotectedHeader : CoseHeader?
	let payload : CBOR
	let signature : Data
	var verifyAlgorithm: VerifyAlgorithm? { guard type == .sign1, let alg = protectedHeader.algorithm else { return nil }; return VerifyAlgorithm(rawValue: alg) }
	var macAlgorithm: MacAlgorithm? { guard type == .mac0, let alg = protectedHeader.algorithm else { return nil }; return MacAlgorithm(rawValue: alg) }

	var keyId : Data? {
		var keyData : Data?
		if let unprotectedKeyId = unprotectedHeader?.keyId {
			keyData = Data(unprotectedKeyId)
		}
		if let protectedKeyId = protectedHeader.keyId {
			keyData = Data(protectedKeyId)
		}
		return keyData
	}
	
	var signatureStruct : Data? {
		get {
			guard let header = protectedHeader.rawHeader else {
				return nil
			}			
			// Structure according to https://tools.ietf.org/html/rfc8152#section-4.2
			switch type {
			case .sign1, .mac0:
				let context = CBOR(stringLiteral: self.type.rawValue)
				let externalAad = CBOR.byteString([UInt8]()) /*no external application specific data*/
				let cborArray = CBOR(arrayLiteral: context, header, externalAad, payload)
				return Data(cborArray.encode())
			}
		}
	}
}

extension Cose {
	init?(type: CoseType, cbor: SwiftCBOR.CBOR) {
		guard let coseList = cbor.asList(), let protectedHeader = CoseHeader(fromBytestring: coseList[0]),
			  let signature = coseList[3].asBytes() else { return nil }
		
		self.protectedHeader = protectedHeader
		self.unprotectedHeader = CoseHeader(fromBytestring: coseList[1]) ?? nil
		self.payload = coseList[2]
		self.signature = Data(signature)
		self.type = type
	}
}


extension Cose: CBOREncodable {
	func toCBOR(options: CBOROptions) -> CBOR {
        .array([protectedHeader.rawHeader ?? .map([:]), unprotectedHeader?.rawHeader ?? .map([:]), payload, .byteString(signature.bytes)])
    }
}
