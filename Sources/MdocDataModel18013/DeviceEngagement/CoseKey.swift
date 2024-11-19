/*
Copyright (c) 2023 European Commission

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
public struct CoseKey: Equatable, Sendable {
	/// EC identifier
	public let crv: CoseEcCurve
	/// key type
    public var kty: UInt64 = 2
	/// value of x-coordinate
    public let x: [UInt8]
	/// value of y-coordinate
    public let y: [UInt8]
}

/// COSE_Key + private key
public struct CoseKeyPrivate: Sendable {

	public var key: CoseKey!
    public var privateKeyId: String!
    public var secureArea: (any SecureArea)!

    public init(privateKeyId: String, secureArea: any SecureArea) {
        logger.info("Loading cose key private with id: \(privateKeyId)")
		self.privateKeyId = privateKeyId
		self.secureArea = secureArea
	}
    
    public init(secureArea: any SecureArea) {
        self.secureArea = secureArea
    }
    
}

extension CoseKeyPrivate {
	// make new key
    public mutating func makeKey(curve: CoseEcCurve) async throws {
        let ephemeralKeyId = UUID().uuidString
        privateKeyId = ephemeralKeyId
        self.key = try await secureArea.createKey(id: ephemeralKeyId, keyOptions: KeyOptions(curve: curve))
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
	public init?(cbor obj: CBOR) {
		guard let calg = obj[-1], case let CBOR.unsignedInt(ralg) = calg, let alg = CoseEcCurve(rawValue: ralg) else { return nil }
		crv = alg
		guard let ckty = obj[1], case let CBOR.unsignedInt(rkty) = ckty else { return nil }
		kty = rkty
		guard let cx = obj[-2], case let CBOR.byteString(rx) = cx else { return nil }
		x = rx
		guard let cy = obj[-3], case let CBOR.byteString(ry) = cy else { return nil }
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
	public func getx963Representation() -> Data {
		let keyData = NSMutableData(bytes: [0x04], length: [0x04].count)
		keyData.append(Data(x))
		keyData.append(Data(y))
		return keyData as Data
	}
    
    public func toSecKey() throws -> SecKey {
        var error: Unmanaged<CFError>?
        guard let publicKey = SecKeyCreateWithData(getx963Representation() as NSData, [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom, kSecAttrKeyClass: kSecAttrKeyClassPublic] as NSDictionary, &error) else {
            throw error!.takeRetainedValue() as Error
        }
        return publicKey
    }
}


/// A COSE_Key exchange pair
public struct CoseKeyExchange: Sendable {
	public let publicKey: CoseKey
	public var privateKey: CoseKeyPrivate

	public init(publicKey: CoseKey, privateKey: CoseKeyPrivate) {
		self.publicKey = publicKey
		self.privateKey = privateKey
	}
}


