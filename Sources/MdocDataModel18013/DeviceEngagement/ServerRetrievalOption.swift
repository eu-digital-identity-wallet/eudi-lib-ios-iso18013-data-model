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

//
//  ServerRetrievalOption.swift

import Foundation
import SwiftCBOR

/// Server retrieval information
public struct ServerRetrievalOption: Codable, Equatable, Sendable {
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
	public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .array(arr) = cbor, arr.count > 2 else { throw .deviceKeyInfoInvalidCbor }
        guard case let .unsignedInt(v) = arr[0], v == Self.versionImpl else { throw .deviceKeyInfoInvalidCbor }
        guard case let .utf8String(u) = arr[1], case let .utf8String(t) = arr[2] else { throw .deviceKeyInfoInvalidCbor }
        version = v; url = u; token = t
    }
}
