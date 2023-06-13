//
//  DrivingPrivilegeCode.swift

import Foundation
import SwiftCBOR

/// Driving privilege code
struct DrivingPrivilegeCode: Codable {
    let code: String
    let sign: String?
    let value: String?
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case code = "code"
        case sign = "sign"
        case value = "value"
    }
}

extension DrivingPrivilegeCode: CBORDecodable {
    init?(cbor: CBOR) {
        guard case let .utf8String(c) = cbor[.utf8String(CodingKeys.code.rawValue)] else { return nil }
        code = c
        if case let .utf8String(s) = cbor[.utf8String(CodingKeys.sign.rawValue)] { sign = s} else { sign = nil }
        if case let .utf8String(v) = cbor[.utf8String(CodingKeys.value.rawValue)] { value = v} else { value = nil }
    }
}

extension DrivingPrivilegeCode: CBOREncodable {
    func toCBOR(options: CBOROptions) -> CBOR {
        var cborMap = [CBOR: CBOR]()
        cborMap[.utf8String(CodingKeys.code.rawValue)] = .utf8String(code)
        if let sign { cborMap[.utf8String(CodingKeys.sign.rawValue)] = .utf8String(sign) }
        if let value { cborMap[.utf8String(CodingKeys.value.rawValue)] = .utf8String(value) }
        return .map(cborMap)
    }
}
