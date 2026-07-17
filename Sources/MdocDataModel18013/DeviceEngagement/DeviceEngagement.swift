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

//  DeviceEngagement.swift

import Foundation
import SwiftCBOR
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif

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
	static let version2 = "1.1"
	var version: String = Self.versionImpl
	var security: Security!
	public var originInfos: [OriginInfoWebsite]? = nil
	public var deviceRetrievalMethods: [DeviceRetrievalMethod]? = nil
	public var serverRetrievalOptions: ServerRetrievalOptions? = nil
	var rfus: [String]?
	// private key data for holder only
    public var privateKey: CoseKeyPrivate?
	public var qrCoded: [UInt8]?


	/// Generate device engagement
	/// - Parameters
	///    - supportsCentralClientMode: true if the holder supports BLE central client mode
	///    - supportsPeripheralServerMode: true if the holder supports BLE peripheral server mode
	///    - crv: The EC curve type used in the mdoc ephemeral private key
    public init?(supportsCentralClientMode: Bool, supportsPeripheralServerMode: Bool, rfus: [String]? = nil) {
		self.rfus = rfus
		let uuid = UUID()
		guard supportsCentralClientMode || supportsPeripheralServerMode else { return nil }
		deviceRetrievalMethods = []
		if supportsCentralClientMode {
			let centralClientMethod = DeviceRetrievalMethod.ble(peripheralServerMode: false, uuid: uuid)
			deviceRetrievalMethods!.append(centralClientMethod)
		}
        if supportsPeripheralServerMode {
			let peripheralServerMethod = DeviceRetrievalMethod.ble(peripheralServerMode: true, uuid: uuid)
			deviceRetrievalMethods!.append(peripheralServerMethod)
		}
	}
	/// initialize from cbor data
	public init(data: [UInt8]) throws {
		guard let obj = try? CBOR.decode(data) else { throw MdocValidationError.invalidCbor("device engagement") }
		try self.init(cbor: obj)
	}

    public mutating func makePrivateKey(secureArea: any SecureArea, keyOptions: KeyOptions) async throws {
        privateKey = try await CoseKeyPrivate(secureArea: secureArea, keyOptions: keyOptions)
		security = Security(deviceKey: try await privateKey!.key)
    }

	public var supportsCentralClientMode: Bool {
		guard let deviceRetrievalMethods else { return false }
		for case let .ble(peripheralServerMode, _, _) in deviceRetrievalMethods {
			return !peripheralServerMode
		}
		return false
	}

	public var supportsPeripheralServerMode: Bool {
		guard let deviceRetrievalMethods else { return false }
		for case let .ble(peripheralServerMode, _, _) in deviceRetrievalMethods {
			return peripheralServerMode
		}
		return false
	}

	public var ble_uuid: String? {
		guard let deviceRetrievalMethods else { return nil}
		for case let .ble(_, uuid, _) in deviceRetrievalMethods {
            return uuid.uuidString
		}
		return nil
	}

	    /// Updates the PSM value on BLE peripheral server mode device retrieval methods.
    public mutating func updatePsm(_ psm: UInt16) {
        guard let methods = deviceRetrievalMethods else { return }
        deviceRetrievalMethods = methods.map { method in
            if case let .ble(peripheralServerMode, uuid, _) = method, peripheralServerMode == true{
                return .ble(peripheralServerMode: peripheralServerMode, uuid: uuid, psm: psm)
            }
            return method
        }
    }
}

extension DeviceEngagement: CBOREncodable {
	public func toCBOR(options: SwiftCBOR.CBOROptions) -> SwiftCBOR.CBOR {
		var res = CBOR.map([0: .utf8String(version), 1: security.toCBOR(options: options)])
		if let drms = deviceRetrievalMethods { res[2] = .array(drms.map { $0.toCBOR(options: options)}) }
		if let sro = serverRetrievalOptions { res[3] = sro.toCBOR(options: options) }
		if let oi = originInfos { res[5] = .array(oi.map {$0.toCBOR(options: CBOROptions()) }) }
		if let rfus = self.rfus { for (i,r) in rfus.enumerated() { res[.negativeInt(UInt64(i))] = .utf8String(r) } }
		logger.debug("DE: \(res.encode().toHexString())")
		return res
	}
}

extension DeviceEngagement: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(map) = cbor else { throw .invalidCbor("device engagement") }
		guard let cv = map[0], case let .utf8String(v) = cv else { throw .invalidCbor("device engagement") }
		try MdocVersion.validateDeviceVersion(v, component: "device engagement")
		guard let cs = map[1] else { throw .invalidCbor("device engagement") }
        security = try Security(cbor: cs)
		if let deviceRetrievalMethodsCbor = map[2],
		   case let .array(retrievalMethodItems) = deviceRetrievalMethodsCbor,
		   retrievalMethodItems.count > 0
		{
			deviceRetrievalMethods = try retrievalMethodItems.map(DeviceRetrievalMethod.init(cbor:))
		}
		if let serverRetrievalOptionsCbor = map[3] {
			serverRetrievalOptions = try ServerRetrievalOptions.init(cbor: serverRetrievalOptionsCbor)
		} else {
			serverRetrievalOptions = nil
		}
		if case let .array(obj5) = map[5] { originInfos = try obj5.map(OriginInfoWebsite.init(cbor:)) }
		version = v
	}
}














