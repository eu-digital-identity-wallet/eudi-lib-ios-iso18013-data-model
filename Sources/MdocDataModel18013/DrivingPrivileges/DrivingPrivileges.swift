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

//  DrivingPrivileges.swift

import Foundation
import SwiftCBOR

///  The DrivingPrivileges structure can be an empty array.
public struct DrivingPrivileges: Codable, Sendable {
	public let drivingPrivileges: [DrivingPrivilege]
	public subscript(i: Int) -> DrivingPrivilege { drivingPrivileges[i] }
}

extension DrivingPrivileges: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .array(dps) = cbor else { throw .drivingPrivilegesInvalidCbor }
		drivingPrivileges = try dps.map { dp throws(MdocValidationError) in try DrivingPrivilege(cbor: dp) }
	}
}

extension DrivingPrivileges: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		return .array(drivingPrivileges.map { $0.toCBOR(options: options) })
	}
}
