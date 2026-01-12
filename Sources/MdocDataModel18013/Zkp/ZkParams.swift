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

import Foundation
import SwiftCBOR
import OrderedCollections

/// ZkSystem: tstr
public typealias ZkSystem = String
public enum ZkParam: CBORDecodable, CBOREncodable, Sendable, Equatable {
    case intParam(Int64)
    case doubleParam(Double)
    case boolParam(Bool)
    case stringParam(String)

    public init(cbor: CBOR) throws(MdocValidationError) {
        switch cbor {
        case let .unsignedInt(value):
            self = .intParam(Int64(value))
        case let .double(value):
            self = .doubleParam(value)
        case let .boolean(value):
            self = .boolParam(value)
        case let .utf8String(value):
            self = .stringParam(value)
        default:
            throw .invalidCbor("ZkParam")
        }
    }
    public func toCBOR(options: CBOROptions) -> CBOR {
        switch self {
        case .intParam(let value):
            return .unsignedInt(UInt64(value))
        case .doubleParam(let value):
            return .double(value)
        case .boolParam(let value):
            return .boolean(value)
        case .stringParam(let value):
            return .utf8String(value)
        }
    }
}
/// ZkParams: { * tstr => Ext }
public typealias ZkParams = OrderedDictionary<String, ZkParam>
