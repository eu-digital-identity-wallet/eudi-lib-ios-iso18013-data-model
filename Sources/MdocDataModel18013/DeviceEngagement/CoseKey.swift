import CryptoKit
import Foundation
import SwiftCBOR

/// crv: EC identifier - Taken from the "COSE Elliptic Curves" registry
public enum ECCurveType: UInt64 {
	case p256 = 1
	case p384 = 2
	case p521 = 3
}

/// COSE_Key as defined in RFC 8152
public struct CoseKey: Equatable {
	/// EC identifier
	public let crv: ECCurveType
	/// key type
	var kty: UInt64 = 2
	/// value of x-coordinate
	let x: [UInt8]
	/// value of y-coordinate
	let y: [UInt8]
}

/// COSE_Key + private key
public struct CoseKeyPrivate  {
	
	public let key: CoseKey
	let d: [UInt8]
	
	init(key: CoseKey, d: [UInt8]) {
		self.key = key
		self.d = d
	}
}

extension CoseKeyPrivate {    
	init(crv: ECCurveType) {
		var privateKeyx963Data: Data
		switch crv {
		case .p256:
			let key = P256.Signing.PrivateKey(compactRepresentable: false)
			privateKeyx963Data = key.x963Representation
		case .p384:
			let key = P384.Signing.PrivateKey(compactRepresentable: false)
			privateKeyx963Data = key.x963Representation
		case .p521:
			let key = P521.Signing.PrivateKey(compactRepresentable: false)
			privateKeyx963Data = key.x963Representation
		}
		let xyk = privateKeyx963Data.advanced(by: 1) //Data(privateKeyx963Data[1...])
		let klen = xyk.count / 3
		let xdata: Data = Data(xyk[0..<klen])
		let ydata: Data = Data(xyk[klen..<2 * klen])
		let ddata: Data = Data(xyk[2 * klen..<3 * klen])
		key = CoseKey(crv: crv, x: xdata.bytes, y: ydata.bytes)
		d = ddata.bytes
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
		guard let calg = obj[-1], case let CBOR.unsignedInt(ralg) = calg, let alg = ECCurveType(rawValue: ralg) else { return nil }
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
	public init(x: [UInt8], y: [UInt8], crv: ECCurveType = .p256) {
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
	public init(x: [UInt8], y: [UInt8], d: [UInt8], crv: ECCurveType = .p256) {
		self.key = CoseKey(x: x, y: y, crv: crv)
		self.d = d
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
public struct CoseKeyExchange {
	public let publicKey: CoseKey
	public let privateKey: CoseKeyPrivate

	public init(publicKey: CoseKey, privateKey: CoseKeyPrivate) {
		self.publicKey = publicKey
		self.privateKey = privateKey
	}
}


