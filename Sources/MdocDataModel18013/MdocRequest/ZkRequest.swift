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

/// ZkRequest
public struct ZkRequest: Sendable {
    public let systemSpecs: [ZkSystemSpec]
    public let extensions: OrderedDictionary<String, CBOR>?
    
    enum Keys: String {
        case systemSpecs
    }
    
    public init(systemSpecs: [ZkSystemSpec], extensions: OrderedDictionary<String, CBOR>? = nil) {
        self.systemSpecs = systemSpecs
        self.extensions = extensions
    }
}

extension ZkRequest: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(m) = cbor else { throw .invalidCbor("ZkRequest") }
        // decode systemSpecs
        guard let systemSpecsValue = m[Keys.systemSpecs] else { throw .missingField("ZkRequest", Keys.systemSpecs.rawValue) }
        guard case let .array(arr) = systemSpecsValue else { throw .invalidCbor("ZkRequest") }
        var specs: [ZkSystemSpec] = []
        for cborItem in arr {
            specs.append(try ZkSystemSpec(cbor: cborItem))
        }
        systemSpecs = specs
        // Parse extensions (other keys in the map)
        var exts: OrderedDictionary<String, CBOR>? = nil
        for (key, value) in m {
            if case let .utf8String(k) = key, k != Keys.systemSpecs.rawValue {
                if exts == nil { exts = OrderedDictionary<String, CBOR>() }
                exts?[k] = value
            }
        }
        self.extensions = exts
    }
}

extension ZkRequest: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var m = OrderedDictionary<CBOR, CBOR>()
        // encode systemSpecs
        m[.utf8String(Keys.systemSpecs.rawValue)] = .array(
            systemSpecs.map { $0.toCBOR(options: options) }
        )
        // encode extensions
        if let extensions {
            for (key, value) in extensions {
                m[.utf8String(key)] = value
            }
        }   
        return .map(m)
    }
}
