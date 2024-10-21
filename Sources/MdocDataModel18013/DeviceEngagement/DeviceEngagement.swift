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

//  DeviceEngagement.swift

import Foundation
import SwiftCBOR
import CryptoKit

/// Device engagement information
///
/// in mdoc holder generate an mdoc ephemeral private key
/// ```swift
/// let de = DeviceEngagement(isBleServer: isBleServer, crv: .p256)
/// // get a UIKit image
/// qrCodeImage = de.getQrCodeImage()
/// // get a string payload
/// qrCodePayload = de.getQrCodePayload()
/// ```
///
/// In mdoc reader decode device engagement CBOR bytes (e.g. from QR code)
/// ```swift
/// let de = DeviceEngagement(data: bytes)
/// ```
public struct DeviceEngagement: Sendable {
	static let versionImpl: String = "1.0"
	var version: String = Self.versionImpl
	let security: Security
	public var originInfos: [OriginInfoWebsite]? = nil
	public var deviceRetrievalMethods: [DeviceRetrievalMethod]? = nil
	public var serverRetrievalOptions: ServerRetrievalOptions? = nil
	var rfus: [String]?
	// private key data for holder only
	var d: [UInt8]?
	var seKeyID: Data?
	public var qrCoded: [UInt8]?
#if DEBUG
	mutating func setD(d: [UInt8]) { self.d = d }
	mutating func setKeyID(keyID: Data) { self.seKeyID = keyID }
#endif
	
	/// Generate device engagement
	/// - Parameters
	///    - isBleServer: true for BLE mdoc peripheral server mode, false for BLE mdoc central client mode
	///    - crv: The EC curve type used in the mdoc ephemeral private key
	public init(isBleServer: Bool?, crv: CoseEcCurve = .P256, rfus: [String]? = nil) {
		let pk: CoseKeyPrivate
		if SecureEnclave.isAvailable, crv == .P256, let se = try? SecureEnclave.P256.KeyAgreement.PrivateKey() {
			pk = CoseKeyPrivate(publicKeyx963Data: se.publicKey.x963Representation, secureEnclaveKeyID: se.dataRepresentation)
			seKeyID = se.dataRepresentation
		} else {
			pk = CoseKeyPrivate(crv: crv)
			d = pk.d
		}
		security = Security(deviceKey: pk.key)
		self.rfus = rfus
		if let isBleServer { deviceRetrievalMethods = [.ble(isBleServer: isBleServer, uuid: DeviceRetrievalMethod.getRandomBleUuid())] }
	}
	/// initialize from cbor data
	public init?(data: [UInt8]) {
		guard let obj = try? CBOR.decode(data) else { return nil }
		self.init(cbor: obj)
	}
	
	public var privateKey: CoseKeyPrivate? {
		if let seKeyID {
			return CoseKeyPrivate(publicKeyx963Data: security.deviceKey.getx963Representation(), secureEnclaveKeyID: seKeyID)
		}
		else if let d {
			return CoseKeyPrivate(key: security.deviceKey, d: d)
		}
		return nil
	}
	
	public var isBleServer: Bool? {
		guard let deviceRetrievalMethods else { return nil}
		for case let .ble(isBleServer, _) in deviceRetrievalMethods {
			return isBleServer
		}
		return nil
	}
	
	public var ble_uuid: String? {
		guard let deviceRetrievalMethods else { return nil}
		for case let .ble(_, uuid) in deviceRetrievalMethods {
			return uuid
		}
		return nil
	}
}

extension DeviceEngagement: CBOREncodable {
	public func toCBOR(options: SwiftCBOR.CBOROptions) -> SwiftCBOR.CBOR {
		var res = CBOR.map([0: .utf8String(version), 1: security.toCBOR(options: options)])
		if let drms = deviceRetrievalMethods { res[2] = .array(drms.map { $0.toCBOR(options: options)}) }
		if let sro = serverRetrievalOptions { res[3] = sro.toCBOR(options: options) }
		if let oi = originInfos { 	res[5] = .array(oi.map {$0.toCBOR(options: CBOROptions()) }) }
		if let rfus = self.rfus { for (i,r) in rfus.enumerated() { res[.negativeInt(UInt64(i))] = .utf8String(r) } }
		logger.debug("DE: \(res.encode().toHexString())")
		return res
	}
}

extension DeviceEngagement: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(map) = cbor else { return nil }
		guard let cv = map[0], case let .utf8String(v) = cv, v.prefix(2) == "1." else { return nil }
		guard let cs = map[1], let s = Security(cbor: cs) else { return nil }
		if let cdrms = map[2], case let .array(drms) = cdrms, drms.count > 0 { deviceRetrievalMethods = drms.compactMap(DeviceRetrievalMethod.init(cbor:)) }
		if let csro = map[3], let sro = ServerRetrievalOptions.init(cbor: csro) { serverRetrievalOptions = sro }
		if case let .array(obj5) = map[5] { originInfos = obj5.compactMap(OriginInfoWebsite.init(cbor:)) }
		version = v; security = s
	}
}














