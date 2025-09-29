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

//  DrivingPrivilegeCode.swift

import Foundation
import SwiftCBOR
import OrderedCollections

/// Driving privilege code
public struct DrivingPrivilegeCode: Codable, Sendable {
	public let code: String
	public let sign: String?
	public let value: String?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case code = "code"
        case sign = "sign"
        case value = "value"
    }
}

extension DrivingPrivilegeCode: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .utf8String(c) = cbor[.utf8String(CodingKeys.code.rawValue)] else { throw .drivingPrivilegeCodeInvalidCbor }
        code = c
        if case let .utf8String(s) = cbor[.utf8String(CodingKeys.sign.rawValue)] { sign = s} else { sign = nil }
        if case let .utf8String(v) = cbor[.utf8String(CodingKeys.value.rawValue)] { value = v} else { value = nil }
    }
}

extension DrivingPrivilegeCode: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        var cborMap = OrderedDictionary<CBOR, CBOR>()
        cborMap[.utf8String(CodingKeys.code.rawValue)] = .utf8String(code)
        if let sign { cborMap[.utf8String(CodingKeys.sign.rawValue)] = .utf8String(sign) }
        if let value { cborMap[.utf8String(CodingKeys.value.rawValue)] = .utf8String(value) }
        return .map(cborMap)
    }
}
