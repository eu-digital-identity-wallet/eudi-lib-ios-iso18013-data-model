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

/// ZkSystemSpec
public struct ZkSystemSpec: Sendable {
    public let system: ZkSystem
    public let params: ZkParams
    public let extensions: OrderedDictionary<String, CBOR>?
    
    enum Keys: String {
        case system
        case params
    }
    
    public init(system: ZkSystem, params: ZkParams, extensions: OrderedDictionary<String, CBOR>? = nil) {
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

extension ZkSystemSpec: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var m = OrderedDictionary<CBOR, CBOR>()
        m[.utf8String(Keys.system.rawValue)] = .utf8String(system)
        // encode params
        var paramsMap = OrderedDictionary<CBOR, CBOR>()
        for (key, value) in params {
            paramsMap[.utf8String(key)] = value.toCBOR(options: options)
        }
        m[.utf8String(Keys.params.rawValue)] = .map(paramsMap)
        // encode extensions
        if let extensions {
            for (key, value) in extensions {
                m[.utf8String(key)] = value
            }
        }
        
        return .map(m)
    }
}
