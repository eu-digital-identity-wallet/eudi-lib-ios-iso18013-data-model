 /*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */

//
//  DeviceRetrievalMethod.swift

import Foundation
import SwiftCBOR

/// A `DeviceRetrievalMethod` holds two mandatory values (type and version). The first element defines the type and the second element the version for the transfer method.
/// Additionally, may contain extra info for each connection.
public enum DeviceRetrievalMethod: Equatable {
    static var version: UInt64 { 1 }
    
    case qr
    case nfc(maxLenCommand: UInt64, maxLenResponse: UInt64)
    case ble(isBleServer: Bool, uuid: String)
    //  case wifiaware // not supported in ios
    static let BASE_UUID_SUFFIX_SERVICE = "-0000-1000-8000-00805F9B34FB".replacingOccurrences(of: "-", with: "")
    static func getRandomBleUuid() -> String {
        let uuidFull = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let index = uuidFull.index(uuidFull.startIndex, offsetBy: 4)
        let uuid = String(uuidFull[index...].prefix(4))
        return "0000\(uuid)\(BASE_UUID_SUFFIX_SERVICE)"
    }
}

extension DeviceRetrievalMethod: CBOREncodable {
    static func appendTypeAndVersion(_ cborArr: inout [CBOR], type: UInt64) {
        cborArr.append(.unsignedInt(type)); cborArr.append(.unsignedInt(version))
    }
	public func toCBOR(options: CBOROptions) -> CBOR {
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

extension DeviceRetrievalMethod: CBORDecodable {
    public init?(cbor: CBOR) {
        guard case let .array(arr) = cbor, arr.count >= 2 else { return nil }
        guard case let .unsignedInt(type) = arr[0] else { return nil }
        guard case let .unsignedInt(v) = arr[1], v == Self.version else { return nil }
        switch type {
        case 0:
            self = .qr
        case 1:
            guard case let .map(options) = arr[2] else { return nil }
            guard case let .unsignedInt(mlc) = options[0], case let .unsignedInt(mlr) = options[1]  else { return nil }
            self = .nfc(maxLenCommand: mlc, maxLenResponse: mlr)
        case 2:
            guard case let .map(options) = arr[2] else { return nil }
            if case let .boolean(b) = options[0], b, case let .byteString(bytes) = options[10] {
                self = .ble(isBleServer: b, uuid: bytes.hex)
            } else if case let .boolean(b) = options[1], b, case let .byteString(bytes) = options[11] {
                self = .ble(isBleServer: !b, uuid: bytes.hex)
            } else { return nil }
        default: return nil
        }
    }
    
}
