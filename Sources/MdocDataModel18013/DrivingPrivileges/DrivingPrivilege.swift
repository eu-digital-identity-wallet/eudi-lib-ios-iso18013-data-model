//
//  DrivingPrivilege.swift

import Foundation
import SwiftCBOR

/// The categories of vehicles/restrictions/conditions contain information describing the driving privileges of the mDL holder
public struct DrivingPrivilege: Codable {
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
	public init?(cbor: CBOR) {
        guard case let .utf8String(v) = cbor[.utf8String(CodingKeys.vehicleCategoryCode.rawValue)] else { return nil }
        vehicleCategoryCode = v
        if let id = cbor[.utf8String(CodingKeys.issueDate.rawValue)]?.decodeFullDate() { issueDate = id} else { issueDate = nil }
        if let ed = cbor[.utf8String(CodingKeys.expiryDate.rawValue)]?.decodeFullDate() { expiryDate = ed} else { expiryDate = nil }
        if case let .array(ac) = cbor[.utf8String(CodingKeys.codes.rawValue)] { codes = ac.compactMap(DrivingPrivilegeCode.init(cbor:)) } else { codes = nil }
    }
}

extension DrivingPrivilege: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        var cborMap = [CBOR: CBOR]()
        cborMap[.utf8String(CodingKeys.vehicleCategoryCode.rawValue)] = .utf8String(vehicleCategoryCode)
        if let issueDate { cborMap[.utf8String(CodingKeys.issueDate.rawValue)] = issueDate.fullDateEncoded }
        if let expiryDate { cborMap[.utf8String(CodingKeys.expiryDate.rawValue)] = expiryDate.fullDateEncoded }
        if let codes { cborMap[.utf8String(CodingKeys.codes.rawValue)] = .array(codes.map { $0.toCBOR(options: options) }) }
        return .map(cborMap)
    }
}
