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

//
//  ServerRetrievalOption.swift

import Foundation
import SwiftCBOR

/// Server retrieval information
public struct ServerRetrievalOption: Codable, Equatable {
    static var versionImpl: UInt64 { 1 }
    var version: UInt64 = Self.versionImpl
    public var url: String
    public var token: String
}

extension ServerRetrievalOption: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        .array([.unsignedInt(Self.versionImpl), .utf8String(url), .utf8String(token) ])
    }
}

extension ServerRetrievalOption: CBORDecodable {
	public init?(cbor: CBOR) {
        guard case let .array(arr) = cbor, arr.count > 2 else { return nil }
        guard case let .unsignedInt(v) = arr[0], v == Self.versionImpl else { return nil }
        guard case let .utf8String(u) = arr[1], case let .utf8String(t) = arr[2] else { return nil }
        version = v; url = u; token = t
    }
}
