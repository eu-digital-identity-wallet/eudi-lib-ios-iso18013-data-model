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
	var kty: UInt64 = 2
	/// value of x-coordinate
	let x: [UInt8]
	/// value of y-coordinate
	let y: [UInt8]
}

/// COSE_Key + private key
public struct CoseKeyPrivate: Sendable {

	public let key: CoseKey
	let d: [UInt8]
	public let secureEnclaveKeyID: Data?

	public init(key: CoseKey, d: [UInt8]) {
		self.key = key
		self.d = d
		self.secureEnclaveKeyID = nil
	}
}

extension CoseKeyPrivate {
	// make new key
	public init(crv: CoseEcCurve) {
		var privateKeyx963Data: Data
		switch crv {
		case .P256:
			let key = P256.KeyAgreement.PrivateKey(compactRepresentable: false)
			privateKeyx963Data = key.x963Representation
		case .P384:
			let key = P384.KeyAgreement.PrivateKey(compactRepresentable: false)
			privateKeyx963Data = key.x963Representation
		case .P521:
			let key = P521.KeyAgreement.PrivateKey(compactRepresentable: false)
			privateKeyx963Data = key.x963Representation
        default: fatalError("Unsupported curve type \(crv)")
		}
		self.init(privateKeyx963Data: privateKeyx963Data, crv: crv)
	}

	public init(privateKeyx963Data: Data, crv: CoseEcCurve = .P256) {
		let xyk = privateKeyx963Data.advanced(by: 1) //Data(privateKeyx963Data[1...])
		let klen = xyk.count / 3
		let xdata: Data = Data(xyk[0..<klen])
		let ydata: Data = Data(xyk[klen..<2 * klen])
		let ddata: Data = Data(xyk[2 * klen..<3 * klen])
		key = CoseKey(crv: crv, x: xdata.bytes, y: ydata.bytes)
		d = ddata.bytes
		secureEnclaveKeyID = nil
	}

	public init(publicKeyx963Data: Data, secureEnclaveKeyID: Data) {
		key = CoseKey(crv: .P256, x963Representation: publicKeyx963Data)
		d = [] // not used
		self.secureEnclaveKeyID = secureEnclaveKeyID
	}

	// decode cbor string
	public init?(base64: String) {
		guard let d = Data(base64Encoded: base64), let obj = try? CBOR.decode([UInt8](d)), let coseKey = CoseKey(cbor: obj), let cd = obj[-4], case let CBOR.byteString(rd) = cd else { return nil }
		self.init(key: coseKey, d: rd)
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

extension CoseKeyPrivate {
	/// Create a COSE_Key from Elliptic Curve paramters of the private key.
	/// - Parameters:
	///   - x: /// value of x-coordinate
	///   - y: /// value of y-coordinate
	///   - d: /// value of x-coordinate
	///   - crv: /// EC identifier
	public init(x: [UInt8], y: [UInt8], d: [UInt8], crv: CoseEcCurve = .P256) {
		self.key = CoseKey(x: x, y: y, crv: crv)
		self.d = d
		self.secureEnclaveKeyID = nil
	}

	/// An ANSI x9.63 representation of the private key.
	public func getx963Representation() -> Data {
		let keyData = NSMutableData(bytes: [0x04], length: [0x04].count)
		keyData.append(Data(key.x))
		keyData.append(Data(key.y))
		keyData.append(Data(d))
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


