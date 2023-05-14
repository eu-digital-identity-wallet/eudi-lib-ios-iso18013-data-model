//
//  DeviceEngagement.swift
//  
//
//  Created by ffeli on 14/05/2023.
//

import Foundation
import SwiftCBOR

struct DeviceEngagement {
}

enum DeviceRetrievalMethod {
    static var version: UInt64 { 1 }
    
    case qr
    case nfc(maxLenCommand: UInt64, maxLenResponse: UInt64)
    case ble(isBleServer: Bool, uuid: String)
    //  case wifiaware // not supported in ios
}

struct ServerRetrievalOption {
    static var version: UInt64 { 1 }
    public var url: String
    public var token: String
}

struct ServerRetrievalOptions  {
    var webAPI: ServerRetrievalOption?
    var oIDC: ServerRetrievalOption?
    var isEmpty:Bool { webAPI == nil && oIDC == nil }
    
    enum Keys : String {
        case webApi
        case oidc
    }
}

struct Security {
    
}

extension ServerRetrievalOption: CBOREncodable {
    func toCBOR(options: CBOROptions) -> CBOR {
        .array([.unsignedInt(Self.version), .utf8String(url), .utf8String(token) ])
    }
}

extension ServerRetrievalOptions: CBOREncodable {
    func toCBOR(options: CBOROptions) -> CBOR {
        var cborMap = [CBOR: CBOR]()
        if let webAPI { cborMap[.utf8String(Keys.webApi.rawValue)] = webAPI.toCBOR(options: options) }
        if let oIDC { cborMap[.utf8String(Keys.oidc.rawValue)] = oIDC.toCBOR(options: options) }
        return .map(cborMap)
    }
}

extension DeviceRetrievalMethod: CBOREncodable {
    static func appendTypeAndVersion(_ cborArr: inout [CBOR], type: UInt64) {
        cborArr.append(.unsignedInt(type)); cborArr.append(.unsignedInt(version))
    }
    func toCBOR(options: CBOROptions) -> CBOR {
        var cborArr = [CBOR]()
        switch self {
        case .qr:
            Self.appendTypeAndVersion(&cborArr, type: 0)
        case .nfc(let maxLenCommand, let maxLenResponse):
            Self.appendTypeAndVersion(&cborArr, type: 1)
            let options: CBOR = [0: .unsignedInt(maxLenCommand), 1: .unsignedInt(maxLenResponse)]
            cborArr.append(options)
        case .ble(let isBleServer, let uuid):
            Self.appendTypeAndVersion(&cborArr, type: 2)
            let options: CBOR = [0: .boolean(isBleServer), 1: .boolean(!isBleServer), .unsignedInt(isBleServer ? 10 : 11): .byteString(uuid.byteArray)]
            cborArr.append(options)
        }
        return .array(cborArr)
    }
}
