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

//  DrivingPrivilege.swift

import Foundation
import SwiftCBOR
import OrderedCollections

/// The categories of vehicles/restrictions/conditions contain information describing the driving privileges of the mDL holder
public struct DrivingPrivilege: Codable, Sendable {
    /// Vehicle category code as per ISO/IEC 18013-1
	public let vehicleCategoryCode: String
    /// Date of issue encoded as full-date
	public let issueDate: String?
    /// Date of expiry encoded as full-date
	public let expiryDate: String?
    /// Array of code info
	public let codes: [DrivingPrivilegeCode]?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case vehicleCategoryCode = "vehicle_category_code"
        case issueDate = "issue_date"
        case expiryDate = "expiry_date"
        case codes = "codes"
    }
}

extension DrivingPrivilege: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
        let vehicleCategoryCodeKey = CBOR.utf8String(CodingKeys.vehicleCategoryCode.rawValue)
        guard case let .utf8String(vehicleCategory) = cbor[vehicleCategoryCodeKey] else { throw .invalidCbor("driving privilege") }
        vehicleCategoryCode = vehicleCategory
        if let id = cbor[.utf8String(CodingKeys.issueDate.rawValue)]?.decodeFullDate() { issueDate = id} else { issueDate = nil }
        if let ed = cbor[.utf8String(CodingKeys.expiryDate.rawValue)]?.decodeFullDate() { expiryDate = ed} else { expiryDate = nil }
        if case let .array(codeArray) = cbor[.utf8String(CodingKeys.codes.rawValue)] {
            codes = try codeArray.map(DrivingPrivilegeCode.init(cbor:))
        } else {
            codes = nil
        }
    }
}

extension DrivingPrivilege: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        var cborMap = OrderedDictionary<CBOR, CBOR>()
        cborMap[.utf8String(CodingKeys.vehicleCategoryCode.rawValue)] = .utf8String(vehicleCategoryCode)
        if let issueDate { cborMap[.utf8String(CodingKeys.issueDate.rawValue)] = issueDate.fullDateEncoded }
        if let expiryDate { cborMap[.utf8String(CodingKeys.expiryDate.rawValue)] = expiryDate.fullDateEncoded }
        if let codes {
            let encodedCodes = codes.map { $0.toCBOR(options: options) }
            cborMap[.utf8String(CodingKeys.codes.rawValue)] = .array(encodedCodes)
        }
        return .map(cborMap)
    }
}
