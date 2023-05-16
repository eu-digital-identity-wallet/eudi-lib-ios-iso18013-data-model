//
//  DeviceEngagement.swift
//  
//
//  Created by ffeli on 14/05/2023.
//

import Foundation
import SwiftCBOR

struct DeviceEngagement {
    static let version: String = "1.0"
    let security: Security
    let deviceRetrievalMethods: [DeviceRetrievalMethod]?
    let serverRetrievalOptions: ServerRetrievalOptions?
}

extension DeviceEngagement: CBOREncodable {
    func toCBOR(options: SwiftCBOR.CBOROptions) -> SwiftCBOR.CBOR {
        var res = CBOR.map([0: .utf8String(Self.version), 1: security.toCBOR(options: options)])
        if let drms = deviceRetrievalMethods { res[2] = .array(drms.map { $0.toCBOR(options: options)}) }
        if let sro = serverRetrievalOptions { res[3] = sro.toCBOR(options: options) }
        return res
    }
}

extension DeviceEngagement: CBORDecodable {
    init?(cbor: CBOR) {
        guard case let .map(map) = cbor else { return nil }
        guard let cv = map[0], case let .utf8String(v) = cv, v.prefix(2) == "1." else { return nil }
        guard let cs = map[1], let s = Security(cbor: cs) else { return nil }
        guard let cdrms = map[2], case let .array(drms) = cdrms, drms.count > 0 else { return nil }
        guard let csro = map[3], let sro = ServerRetrievalOptions.init(cbor: csro) else { return nil }
        security = s; deviceRetrievalMethods = drms.compactMap(DeviceRetrievalMethod.init(cbor:))
        serverRetrievalOptions = sro
    }
}














