//
//  DeviceEngagement.swift
//  
//
//  Created by ffeli on 14/05/2023.
//

import Foundation
import SwiftCBOR

/// Device engagement information
///
/// in mdoc holder generate an mdoc ephemeral private key
/// ```swift
/// let de = DeviceEngagement(isBleServer: isBleServer, crv: .p256)
/// qrCodeImage = de.getQrCodeImage()
/// ```
///
/// In mdoc reader decode device engagement CBOR bytes (e.g. from QR code)
/// ```swift
/// let de = DeviceEngagement(data: bytes)
/// ```
public struct DeviceEngagement {
    static let versionImpl: String = "1.0"
    var version: String = Self.versionImpl
    let security: Security
    var deviceRetrievalMethods: [DeviceRetrievalMethod]? = nil
    var serverRetrievalOptions: ServerRetrievalOptions? = nil
	// private key data for holder only
    var d: [UInt8]?
    #if DEBUG
    mutating func setD(d: [UInt8]) { self.d = d }
    #endif

	/// Generate device engagement
	/// - Parameters
	///    - isBleServer: true for BLE mdoc peripheral server mode, false for BLE mdoc central client mode
	///    - crv: The EC curve type used in the mdoc ephemeral private key
    public init(isBleServer: Bool?, crv: ECCurveType = .p256) {
        let pk = CoseKeyPrivate(crv: crv)
        security = Security(deviceKey: pk.key)
        d = pk.d
        if let isBleServer {
            deviceRetrievalMethods = [.ble(isBleServer: isBleServer, uuid: DeviceRetrievalMethod.getRandomBleUuid())]
        }
    }
    /// initialize from cbor data
    public init?(data: [UInt8]) {
        guard let obj = try? CBOR.decode(data) else { return nil }
        self.init(cbor: obj)
    }

    public var privateKey: CoseKeyPrivate? {
        guard let d else { return nil }
        return CoseKeyPrivate(key: security.deviceKey, d: d)
     }
}

extension DeviceEngagement: CBOREncodable {
    public func toCBOR(options: SwiftCBOR.CBOROptions) -> SwiftCBOR.CBOR {
        var res = CBOR.map([0: .utf8String(version), 1: security.toCBOR(options: options)])
        if let drms = deviceRetrievalMethods { res[2] = .array(drms.map { $0.toCBOR(options: options)}) }
        if let sro = serverRetrievalOptions { res[3] = sro.toCBOR(options: options) }
        return res
    }
    public func encode(options: CBOROptions) -> [UInt8] { toCBOR(options: options).encode(options: options) }
}


extension DeviceEngagement: CBORDecodable {
    public init?(cbor: CBOR) {
        guard case let .map(map) = cbor else { return nil }
        guard let cv = map[0], case let .utf8String(v) = cv, v.prefix(2) == "1." else { return nil }
        guard let cs = map[1], let s = Security(cbor: cs) else { return nil }
        if let cdrms = map[2], case let .array(drms) = cdrms, drms.count > 0 { deviceRetrievalMethods = drms.compactMap(DeviceRetrievalMethod.init(cbor:)) }
        if let csro = map[3], let sro = ServerRetrievalOptions.init(cbor: csro) { serverRetrievalOptions = sro }
        version = v; security = s
    }
}














