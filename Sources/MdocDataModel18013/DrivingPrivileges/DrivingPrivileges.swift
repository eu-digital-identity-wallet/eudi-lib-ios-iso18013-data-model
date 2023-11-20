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

//  DrivingPrivileges.swift

import Foundation
import SwiftCBOR

///  The DrivingPrivileges structure can be an empty array.
public struct DrivingPrivileges: Codable {
	public let drivingPrivileges: [DrivingPrivilege]
	public subscript(i: Int) -> DrivingPrivilege { drivingPrivileges[i] }
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
