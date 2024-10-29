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

import CryptoKit
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

	public var key: CoseKey
    public let privateKeyId: String
    public let secureArea: any SecureArea

    public init(key: CoseKey?, privateKeyId: String, secureArea: any SecureArea) throws {
        logger.info("Loading cose key private with id: \(privateKeyId)")
		self.privateKeyId = privateKeyId
		self.secureArea = secureArea
        if let key { self.key = key } else { let ki = try secureArea.getKeyInfo(id: privateKeyId); self.key = ki.publicKey }
	}
}

extension CoseKeyPrivate {
	// make new key
	public init(curve: CoseEcCurve, secureArea: any SecureArea) throws {
        let ephemeralKeyId = UUID().uuidString
        let (_, coseKey) = try secureArea.createKey(id: ephemeralKeyId, keyOptions: KeyOptions(curve: curve))
        try self.init(key: coseKey, privateKeyId: ephemeralKeyId, secureArea: secureArea)
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
}


/// A COSE_Key exchange pair
public struct CoseKeyExchange: Sendable {
	public let publicKey: CoseKey
	public let privateKey: CoseKeyPrivate

	public init(publicKey: CoseKey, privateKey: CoseKeyPrivate) {
		self.publicKey = publicKey
		self.privateKey = privateKey
	}
}


