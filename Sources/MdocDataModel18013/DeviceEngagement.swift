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





struct Security {
    
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

