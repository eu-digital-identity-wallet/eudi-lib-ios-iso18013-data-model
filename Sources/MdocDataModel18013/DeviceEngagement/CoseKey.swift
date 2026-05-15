/*
Copyright (c) 2026 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif
import Foundation
import SwiftCBOR

/// COSE_Key as defined in RFC 8152
public struct CoseKey: Equatable, Codable, Sendable {
	/// EC identifier
	public let crv: CoseEcCurve
	/// key type
    public var kty: UInt64 = 2
	/// value of x-coordinate
    public let x: [UInt8]
	/// value of y-coordinate
    public let y: [UInt8]

    public enum Keys: String {
        case crv
        case kty
        case x
        case y
    }
}

/// COSE_Key + private key
public struct CoseKeyPrivate: Sendable {

	private var cachedKey: CoseKey?
    public var privateKeyId: String
    public var index: Int
    public var secureArea: (any SecureArea)
	private var curve: CoseEcCurve

	public var key: CoseKey {
		mutating get async throws {
			if let cachedKey {
				return cachedKey
			}
			///guard let privateKeyId, let index, let curve else {
			//	throw SecureAreaError("Cannot load public key: key reference is incomplete")
			//}
			let loadedKey = try await secureArea.getPublicKey(id: privateKeyId, index: index, curve: curve)
			self.cachedKey = loadedKey
			return loadedKey
		}
	}

	/// Initialize with existing key in secure area
    public init(privateKeyId: String, index: Int, secureArea: any SecureArea, curve: CoseEcCurve) {
        logger.info("Loading cose key private with id: \(privateKeyId)")
		self.privateKeyId = privateKeyId
        self.index = index
		self.secureArea = secureArea
		self.curve = curve
	}

    public init(secureArea: any SecureArea, curve: CoseEcCurve)  async throws {
        index = 0
        privateKeyId = UUID().uuidString
        self.secureArea = secureArea
		self.curve = curve
        let createdKeys = try await secureArea.createKeyBatch(
            id: privateKeyId,
            credentialOptions: CredentialOptions(credentialPolicy: .rotateUse, batchSize: 1),
            keyOptions: KeyOptions(curve: curve)
        )
        guard let firstKey = createdKeys.first else {
            throw SecureAreaError("Secure area returned an empty key batch")
        }
		self.cachedKey = firstKey
	}
}

extension CoseKey: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		let cbor: CBOR = [
			-1: .unsignedInt(crv.rawValue), 1: .unsignedInt(kty),
			 -2: .byteString(x), -3: .byteString(y),
		]
		return cbor
	}
}

extension CoseKey: CBORDecodable {
	public init(cbor obj: CBOR) throws(MdocValidationError) {
		guard let curveCbor = obj[-1], case let CBOR.unsignedInt(rawCurveIdentifier) = curveCbor, let curve = CoseEcCurve(rawValue: rawCurveIdentifier) else {
			throw .invalidCbor("COSE key")
		}
		crv = curve
		guard let keyTypeCbor = obj[1], case let CBOR.unsignedInt(rawKeyType) = keyTypeCbor else { throw .missingField("CoseKey", Keys.kty.rawValue) }
		kty = rawKeyType
		guard let cx = obj[-2], case let CBOR.byteString(rx) = cx else { throw .missingField("CoseKey", Keys.x.rawValue) }
		x = rx
		guard let cy = obj[-3], case let CBOR.byteString(ry) = cy else { throw .missingField("CoseKey", Keys.y.rawValue) }
		y = ry
	}
}

extension CoseKey {
	public init(crv: CoseEcCurve, x963Representation: Data) {
		let keyData = x963Representation.dropFirst().bytes
		let count = keyData.count/2
		self.init(x: Array(keyData[0..<count]), y: Array(keyData[count...]), crv: crv)
	}

	public init(x: [UInt8], y: [UInt8], crv: CoseEcCurve = .P256) {
		self.crv = crv
		self.x = x
		self.y = y
	}
	/// An ANSI x9.63 representation of the public key.
    public var x963Representation: Data {
		let keyData = NSMutableData(bytes: [0x04], length: [0x04].count)
		keyData.append(Data(x))
		keyData.append(Data(y))
		return keyData as Data
	}

    public func toSecKey() throws -> SecKey {
        var error: Unmanaged<CFError>?
		let secKeyAttributes: NSDictionary = [
			kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
			kSecAttrKeyClass: kSecAttrKeyClassPublic,
		]
		guard let publicKey = SecKeyCreateWithData(x963Representation as NSData, secKeyAttributes, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return publicKey
    }
}


/// A COSE_Key exchange pair
public struct CoseKeyExchange: Sendable {
	public let publicKey: CoseKey?
	public var privateKey: CoseKeyPrivate

	public init(publicKey: CoseKey?, privateKey: CoseKeyPrivate) {
		self.publicKey = publicKey
		self.privateKey = privateKey
	}
}


