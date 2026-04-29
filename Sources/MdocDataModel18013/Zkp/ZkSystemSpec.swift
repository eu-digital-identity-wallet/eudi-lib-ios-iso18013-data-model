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

import Foundation
import SwiftyJSON
import SwiftCBOR
import OrderedCollections

/// ZkSystemSpec
public struct ZkSystemSpec: Sendable, Identifiable {
    public let zkSystemId: String
    public let system: ZkSystem
    public let params: ZkParams
    public let extensions: OrderedDictionary<String, CBOR>?

    public var id: String { zkSystemId }

    enum Keys: String {
        case zkSystemId
        case system
        case params
    }

    public init(zkSystemId: String, system: ZkSystem, params: ZkParams, extensions: OrderedDictionary<String, CBOR>? = nil) {
        self.zkSystemId = zkSystemId
        self.system = system
        self.params = params
        self.extensions = extensions
    }
}

extension ZkSystemSpec: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(m) = cbor else { throw .invalidCbor("ZkSystemSpec") }
        guard let systemValue = m[Keys.system] else { throw .missingField("ZkSystemSpec", Keys.system.rawValue) }
        guard case let .utf8String(sys) = systemValue else { throw .invalidCbor("ZkSystemSpec") }
        system = sys
        if case let .utf8String(tid) = m[Keys.zkSystemId] { zkSystemId = tid } else { zkSystemId = sys }
        // decode params
        guard let paramsValue = m[Keys.params] else { throw .missingField("ZkSystemSpec", Keys.params.rawValue) }
        guard case let .map(paramsMap) = paramsValue else { throw .invalidCbor("ZkSystemSpec") }
        var zkParams = OrderedDictionary<String, ZkParam>()
        for (key, value) in paramsMap {
            guard case let .utf8String(k) = key else { throw .invalidCbor("ZkSystemSpec") }
            zkParams[k] = try ZkParam(cbor: value)
        }
        params = zkParams
        // Parse extensions (other keys in the map)
        var exts: OrderedDictionary<String, CBOR>? = nil
        for (key, value) in m {
            if case let .utf8String(k) = key,
               k != Keys.system.rawValue &&
               k != Keys.params.rawValue {
                if exts == nil { exts = OrderedDictionary<String, CBOR>() }
                exts?[k] = value
            }
        }
        self.extensions = exts
    }
}

extension ZkSystemSpec {
    /// Initialize from a JSON dictionary (e.g. decoded from `JSONSerialization`).
    /// The `"system"` key is **required** and maps to ``system``.
    /// Every other key/value pair is converted to a ``ZkParam`` and stored in ``params``.
    public init(jsonObject: JSON) throws {
        guard let sys = jsonObject[Keys.system.rawValue].string else {
            throw MdocValidationError.missingField("ZkSystemSpec", Keys.system.rawValue)
        }
        self.system = sys
        // Use explicit "zkSystemId" if present, otherwise fall back to system value
        if let idValue = jsonObject[Keys.zkSystemId.rawValue].string { self.zkSystemId = idValue }
        else { self.zkSystemId = sys }
        // All keys except "system" and "zkSystemId" become params
        var zkParams = OrderedDictionary<String, ZkParam>()
        for (key, value) in jsonObject {
            guard key != Keys.system.rawValue, key != Keys.zkSystemId.rawValue else { continue }
            zkParams[key] = try Self.zkParam(from: value, key: key)
        }
        self.params = zkParams
        self.extensions = nil
    }

    /// Initialize from raw JSON `Data`.
    public init(jsonData: Data) throws {
        guard let obj = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw MdocValidationError.invalidCbor("ZkSystemSpec JSON root is not a dictionary")
        }
        try self.init(jsonObject: JSON(obj))
    }

    private static func zkParam(from value: JSON, key: String) throws -> ZkParam {
        switch value.type {
        case .number:
            if let intVal = value.int64 {
                return .intParam(intVal)
            } else if let doubleVal = value.double {
                return .doubleParam(doubleVal)
            }
        case .bool:
            if let boolVal = value.bool {
                return .boolParam(boolVal)
            }
        case .string:
            if let strVal = value.string {
                return .stringParam(strVal)
            }
        default: break
        }
        throw MdocValidationError.invalidCbor("ZkSystemSpec param '\(key)' has unsupported type")
    }
}

extension Array where Element == ZkSystemSpec {
    /// given a JSON object containing a "zk_system_type" array, initialize an array of `ZkSystemSpec` from it.
    /// https://developers.google.com/wallet/identity/verify/accepting-ids-from-wallet-online#zkp
    public init(meta: JSON) throws {
        self = try meta["zk_system_type"].array?.map { try ZkSystemSpec(jsonObject: $0) } ?? []
    }
    /// Initialize an array of `ZkSystemSpec` from a JSON array.
    public init(jsonArray: [JSON]) throws {
        self = try jsonArray.map { try ZkSystemSpec(jsonObject: $0) }
    }
}

extension ZkSystemSpec: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var map = OrderedDictionary<CBOR, CBOR>()
        map[.utf8String(Keys.system.rawValue)] = .utf8String(system)
        // encode params
        var paramsMap = OrderedDictionary<CBOR, CBOR>()
        for (key, value) in params {
            paramsMap[.utf8String(key)] = value.toCBOR(options: options)
        }
        map[.utf8String(Keys.params.rawValue)] = .map(paramsMap)
        // encode extensions
        if let extensions {
            for (key, value) in extensions {
                map[.utf8String(key)] = value
            }
        }

        return .map(map)
    }
}
