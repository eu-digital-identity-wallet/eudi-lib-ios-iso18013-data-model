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

//
//  DeviceRetrievalMethod.swift

import Foundation
import SwiftCBOR

/// A `DeviceRetrievalMethod` holds two mandatory values (type and version). The first element defines the type and the second element the version for the transfer method.
/// Additionally, may contain extra info for each connection.
public enum DeviceRetrievalMethod: Equatable, Sendable {
    static var version: UInt64 { 1 }

    case nfc(maxLenCommand: UInt64, maxLenResponse: UInt64)
    case ble(peripheralServerMode: Bool, uuid: UUID, psm: UInt16? = nil) // psm is optional for future use, not used in current version
    //  case wifiaware // not supported in ios
}

extension DeviceRetrievalMethod: CBOREncodable {
    static func appendTypeAndVersion(_ cborArr: inout [CBOR], type: UInt64) {
        cborArr.append(.unsignedInt(type)); cborArr.append(.unsignedInt(version))
    }
	public func toCBOR(options: CBOROptions) -> CBOR {
        var cborArr = [CBOR]()
        switch self {
        case .nfc(let maxLenCommand, let maxLenResponse):
            Self.appendTypeAndVersion(&cborArr, type: 1)
            let options: CBOR = [0: .unsignedInt(maxLenCommand), 1: .unsignedInt(maxLenResponse)]
            cborArr.append(options)
        case .ble(let peripheralServerMode, let uuid, let psm):
            Self.appendTypeAndVersion(&cborArr, type: 2)
            let modeSpecificOptionKey: CBOR = .unsignedInt(peripheralServerMode ? 10 : 11)
            let compactUuidString = uuid.uuidString.replacingOccurrences(of: "-", with: "")
            let compactUuidBytes = compactUuidString.byteArray
            var options: CBOR = [
                0: .boolean(peripheralServerMode),
                1: .boolean(!peripheralServerMode),
                modeSpecificOptionKey: .byteString(compactUuidBytes),
            ]
            if let psm { options[21] = .unsignedInt(UInt64(psm)) }
            cborArr.append(options)
        }
        return .array(cborArr)
    }
}

extension DeviceRetrievalMethod: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .array(arr) = cbor, arr.count >= 2 else { throw .invalidCbor("device retrieval method") }
        guard case let .unsignedInt(type) = arr[0] else { throw .invalidCbor("device retrieval method") }
		guard case let .unsignedInt(methodVersion) = arr[1], methodVersion == Self.version else { throw .invalidCbor("device retrieval method") }
        switch type {
        case 1:
            guard case let .map(options) = arr[2] else { throw .invalidCbor("device retrieval method") }
			guard case let .unsignedInt(maxLenCommand) = options[0], case let .unsignedInt(maxLenResponse) = options[1]  else { throw .invalidCbor("device retrieval method") }
			self = .nfc(maxLenCommand: maxLenCommand, maxLenResponse: maxLenResponse)
        case 2:
            guard case let .map(options) = arr[2] else { throw .invalidCbor("device retrieval method") }
            let psm: UInt16? = if case let .unsignedInt(rawPsm) = options[21] { UInt16(rawPsm) } else { nil }
            if case let .boolean(isPeripheralServerMode) = options[0], isPeripheralServerMode,
               case let .byteString(uuidBytes) = options[10],
               let uuid = UUID(uuidBytes: uuidBytes)
            {
                self = .ble(peripheralServerMode: isPeripheralServerMode, uuid: uuid, psm: psm)
            } else if case let .boolean(isCentralClientMode) = options[1], isCentralClientMode,
                      case let .byteString(uuidBytes) = options[11],
                      let uuid = UUID(uuidBytes: uuidBytes)
            {
				self = .ble(peripheralServerMode: !isCentralClientMode, uuid: uuid, psm: psm)
            } else { throw .invalidCbor("device retrieval method") }
        default: throw .invalidCbor("device retrieval method")
        }
    }

}
