//
//  DrivingPrivileges.swift

import Foundation
import SwiftCBOR

///  The DrivingPrivileges structure can be an empty array.
struct DrivingPrivileges {
  let drivingPrivileges: [DrivingPrivilege]
}

extension DrivingPrivileges: CBORDecodable {
    init?(cbor: CBOR) {
        guard case let .array(dp) = cbor else { return nil }
        drivingPrivileges = dp.compactMap(DrivingPrivilege.init(cbor:))
    }
}

extension DrivingPrivileges: CBOREncodable {
    func toCBOR(options: CBOROptions) -> CBOR {
        return .array(drivingPrivileges.map { $0.toCBOR(options: options) }) 
    }
}
