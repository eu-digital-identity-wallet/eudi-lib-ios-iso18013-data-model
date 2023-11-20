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

//  DrivingPrivilegeCode.swift

import Foundation
import SwiftCBOR

/// Driving privilege code
public struct DrivingPrivilegeCode: Codable {
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
	public init?(cbor: CBOR) {
        guard case let .utf8String(c) = cbor[.utf8String(CodingKeys.code.rawValue)] else { return nil }
        code = c
        if case let .utf8String(s) = cbor[.utf8String(CodingKeys.sign.rawValue)] { sign = s} else { sign = nil }
        if case let .utf8String(v) = cbor[.utf8String(CodingKeys.value.rawValue)] { value = v} else { value = nil }
    }
}

extension DrivingPrivilegeCode: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        var cborMap = [CBOR: CBOR]()
        cborMap[.utf8String(CodingKeys.code.rawValue)] = .utf8String(code)
        if let sign { cborMap[.utf8String(CodingKeys.sign.rawValue)] = .utf8String(sign) }
        if let value { cborMap[.utf8String(CodingKeys.value.rawValue)] = .utf8String(value) }
        return .map(cborMap)
    }
}
