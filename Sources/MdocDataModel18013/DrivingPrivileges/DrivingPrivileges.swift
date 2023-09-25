//
//  DrivingPrivileges.swift

import Foundation
import SwiftCBOR

///  The DrivingPrivileges structure can be an empty array.
public struct DrivingPrivileges: Codable {
	public let drivingPrivileges: [DrivingPrivilege]
	subscript(i: Int) -> DrivingPrivilege { drivingPrivileges[i] }
}

extension DrivingPrivileges: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .array(dp) = cbor else { return nil }
		drivingPrivileges = dp.compactMap(DrivingPrivilege.init(cbor:))
	}
}

extension DrivingPrivileges: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		return .array(drivingPrivileges.map { $0.toCBOR(options: options) })
	}
}
