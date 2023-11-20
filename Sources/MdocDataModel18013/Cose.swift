 /*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */

//  Cose.swift

import Foundation
import SwiftCBOR
//

extension Cose {
	/// COSE Message Identification
	public enum CoseType : String {
		/// COSE Single Signer Data Object
		/// Only one signature is applied on the message payload
		case sign1 = "Signature1"
		case mac0 = "MAC0"
		/// Idenntifies Cose Message Type from input data
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
	public enum VerifyAlgorithm: UInt64 {
		case es256 = 6 //-7 ECDSA w/ SHA-256
		case es384 = 34 //-35 ECDSA w/ SHA-384
		case es512 = 35//-36 ECDSA w/ SHA-512
	}
	
	/// MAC Algorithm Values
	///
	/// Table 7  in rfc/rfc8152#section-16.2
	public enum MacAlgorithm: UInt64 {
		case hmac256 = 5 //HMAC w/ SHA-256
		case hmac384 = 6 //HMAC w/ SHA-384
		case hmac512 = 7 //HMAC w/ SHA-512
	}
}

extension Cose {
	/// Cose header structure defined in https://datatracker.ietf.org/doc/html/rfc8152
	struct CoseHeader {
		enum Headers : Int {
			case keyId = 4
			case algorithm = 1
		}
		
		let rawHeader : CBOR?
		let keyId : [UInt8]?
		let algorithm : UInt64?
		
		// MARK: - Initializers
		/// Initialize from CBOR
		/// - Parameter cbor: CBOR representation of the header
		init?(fromBytestring cbor: CBOR){
			guard let cborMap = cbor.decodeBytestring()?.asMap(),
				  let alg = cborMap[Headers.algorithm]?.asUInt64() else {
				self.init(alg: nil, isNegativeAlg: nil, keyId: nil, rawHeader: cbor)
				return
			}
			self.init(alg: alg, isNegativeAlg: nil, keyId: cborMap[Headers.keyId]?.asBytes(), rawHeader: cbor)
		}
		
		public init?(alg: UInt64?, isNegativeAlg: Bool?, keyId: [UInt8]?, rawHeader : CBOR? = nil){
			guard alg != nil || rawHeader != nil else { return nil }
			self.algorithm = alg
			self.keyId = keyId
			func algCbor() -> CBOR { isNegativeAlg! ? .negativeInt(alg!) : .unsignedInt(alg!) }
			self.rawHeader = rawHeader ?? .byteString(CBOR.map([.unsignedInt(UInt64(Headers.algorithm.rawValue)) : algCbor()]).encode())
		}
	}
}

 /// Struct which describes  a representation for cryptographic keys;  how to create and process signatures, message authentication codes, and  encryption using Concise Binary Object Representation (CBOR) or serialization.
public struct Cose {
	public let type: CoseType
	let protectedHeader : CoseHeader
	let unprotectedHeader : CoseHeader?
	public let payload : CBOR
	public let signature : Data

	public var verifyAlgorithm: VerifyAlgorithm? { guard type == .sign1, let alg = protectedHeader.algorithm else { return nil }; return VerifyAlgorithm(rawValue: alg) }
	public var macAlgorithm: MacAlgorithm? { guard type == .mac0, let alg = protectedHeader.algorithm else { return nil }; return MacAlgorithm(rawValue: alg) }

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
	
	/// Structure according to https://tools.ietf.org/html/rfc8152#section-4.2
	public var signatureStruct : Data? {
		get {
			guard let header = protectedHeader.rawHeader else {
				return nil
			}			
			switch type {
			case .sign1, .mac0:
				let context = CBOR(stringLiteral: self.type.rawValue)
				let externalAad = CBOR.byteString([UInt8]()) //no external application specific data
				let cborArray = CBOR(arrayLiteral: context, header, externalAad, payload)
				return Data(cborArray.encode())
			}
		}
	}
}

extension Cose {
	///initializer to create a cose message from a cbor representation
	/// - Parameters:
	///  - type: Cose message type
	///  - cbor: CBOR representation of the cose message
	public init?(type: CoseType, cbor: SwiftCBOR.CBOR) {
		guard let coseList = cbor.asList(), let protectedHeader = CoseHeader(fromBytestring: coseList[0]),
			  let signature = coseList[3].asBytes() else { return nil }
		
		self.protectedHeader = protectedHeader
		self.unprotectedHeader = CoseHeader(fromBytestring: coseList[1]) ?? nil
		self.payload = coseList[2]
		self.signature = Data(signature)
		self.type = type
	}
	///initializer to create a detached cose signature
	public init(type: CoseType, algorithm: UInt64, signature: Data) {
		self.protectedHeader = CoseHeader(alg: algorithm, isNegativeAlg: type == .sign1, keyId: nil)!
		self.unprotectedHeader = nil
		self.payload = .null
		self.signature = signature
		self.type = type
	}
	///initializer to create a payload cose message
	public init(type: CoseType, algorithm: UInt64, payloadData: Data, unprotectedHeaderCbor: CBOR? = nil, signature: Data? = nil) {
		self.protectedHeader = CoseHeader(alg: algorithm, isNegativeAlg: type == .sign1, keyId: nil)!
		self.unprotectedHeader = unprotectedHeaderCbor != nil ? CoseHeader(alg: nil, isNegativeAlg: nil, keyId: nil, rawHeader: unprotectedHeaderCbor!) : nil
		self.payload = .byteString(payloadData.bytes)
		self.signature = signature ?? Data()
		self.type = type
	}
	///initializer to create a cose message from a detached cose and a payload
	/// - Parameters:
	/// - other: detached cose message
	/// - payloadData: payload data
	public init(other: Cose, payloadData: Data) {
		self.protectedHeader = other.protectedHeader
		self.unprotectedHeader = other.unprotectedHeader
		self.payload = .byteString(payloadData.bytes)
		self.signature = other.signature
		self.type = other.type
	}
}

extension Cose: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        .array([protectedHeader.rawHeader ?? .map([:]), unprotectedHeader?.rawHeader ?? .map([:]), payload, .byteString(signature.bytes)])
    }
}
