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
		/// COSE Signed Data Object
		/// One or more signature is applied on the message payload
		case sign = "Signature"
		
		/// Identtifies Cose Message Type from input data
		static func from(data: Data) -> CoseType? {
			guard let cose = try? CBORDecoder(input: data.bytes).decodeItem()?.asCose() else {
				return nil
			}
			
			switch cose.0 {
			case .coseSign1Item:
				return .sign1
				
			case .coseSignItem:
				return .sign
				
			default:
				return nil
			}
		}
	}
}

extension Cose {
	
	struct CoseHeader {
		enum Headers : Int {
			case keyId = 4
			case algorithm = 1
		}
		
		enum Algorithm : UInt64 {
			case es256 = 6 //-7
			case ps256 = 36 //-37
		}
		
		let rawHeader : CBOR?
		let keyId : [UInt8]?
		let algorithm : Algorithm?
		
		// MARK: - Initializers
		
		init?(fromBytestring cbor: CBOR){
			guard let cborMap = cbor.decodeBytestring()?.asMap(),
				  let algValue = cborMap[Headers.algorithm]?.asUInt64(),
				  let alg = Algorithm(rawValue: algValue) else {
				self.init(alg: nil, keyId: nil, rawHeader: cbor)
				return
			}
			
			self.init(alg: alg, keyId: cborMap[Headers.keyId]?.asBytes(), rawHeader: cbor)
		}
		
		init?(from cbor: CBOR) {
			let cborMap = cbor.asMap()
			var alg : Algorithm?
			
			if let algValue = cborMap?[Headers.algorithm]?.asUInt64() {
				alg = Algorithm(rawValue: algValue)
			}
			
			self.init(alg: alg, keyId: cborMap?[Headers.keyId]?.asBytes())
		}
		// MARK: - Private
		private init(alg: Algorithm?, keyId: [UInt8]?, rawHeader : CBOR? = nil){
			self.algorithm = alg
			self.keyId = keyId
			self.rawHeader = rawHeader
		}
	}
}

/**
 Struct which describes  a representation for cryptographic keys;
 how to create and process signatures, message authentication codes, and
 encryption using Concise Binary Object Representation (CBOR) or serialization.
 */

struct Cose {
	let type: CoseType
	let protectedHeader : CoseHeader
	let unprotectedHeader : CoseHeader?
	let payload : CBOR
	let signature : Data
	
	var keyId : Data? {
		get {
			var keyData : Data?
			
			if let unprotectedKeyId = unprotectedHeader?.keyId {
				keyData = Data(unprotectedKeyId)
			}
			
			if let protectedKeyId = protectedHeader.keyId {
				keyData = Data(protectedKeyId)
			}
			
			return keyData
		}
	}
	
	var signatureStruct : Data? {
		get {
			guard let header = protectedHeader.rawHeader else {
				return nil
			}
			
			/* Structure according to https://tools.ietf.org/html/rfc8152#section-4.2 */
			switch type {
			case .sign1:
				let context = CBOR(stringLiteral: self.type.rawValue)
				let externalAad = CBOR.byteString([UInt8]()) /*no external application specific data*/
				let cborArray = CBOR(arrayLiteral: context, header, externalAad, payload)
				return Data(cborArray.encode())
				
			default:
				print("COSE Sign messages are not yet supported.")
				return nil
			}
		}
	}
}

extension Cose: CBORDecodable {
	init?(cbor: SwiftCBOR.CBOR) {
		guard let coseList = cbor.asList(),  let protectedHeader = CoseHeader(fromBytestring: coseList[0]),
			  let signature = coseList[3].asBytes() else { return nil}
		
		self.protectedHeader = protectedHeader
		self.unprotectedHeader = CoseHeader(fromBytestring: coseList[1]) ?? nil
		self.payload = coseList[2]
		self.signature = Data(signature)
		self.type = .sign1
	}
	
}

