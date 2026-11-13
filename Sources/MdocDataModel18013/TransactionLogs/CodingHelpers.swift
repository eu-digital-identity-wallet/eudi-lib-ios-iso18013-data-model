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

/// Codes a value that TS10 examples sometimes render as a single object and sometimes as an array.
@propertyWrapper
public struct OneOrManyCoded<Element: Codable & Equatable & Sendable>: Codable, Equatable, Sendable, ExpressibleByNilLiteral {
    public var wrappedValue: [Element]?

    public init(wrappedValue: [Element]?) {
        self.wrappedValue = wrappedValue
    }

    /// Lets the synthesized Codable use decodeIfPresent/encodeIfPresent when the key is absent.
    public init(nilLiteral: ()) {
        self.wrappedValue = nil
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            wrappedValue = nil
        } else if let array = try? container.decode([Element].self) {
            wrappedValue = array
        } else {
            wrappedValue = [try container.decode(Element.self)]
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

/// Codes a boolean that TS10 examples sometimes render as a native boolean and sometimes as the
/// string `"TRUE"`/`"FALSE"`.
@propertyWrapper
public struct LenientBoolCoded: Codable, Equatable, Sendable, ExpressibleByNilLiteral {
    public var wrappedValue: Bool?

    public init(wrappedValue: Bool?) {
        self.wrappedValue = wrappedValue
    }

    /// Lets the synthesized Codable use decodeIfPresent/encodeIfPresent when the key is absent.
    public init(nilLiteral: ()) {
        self.wrappedValue = nil
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            wrappedValue = nil
        } else if let bool = try? container.decode(Bool.self) {
            wrappedValue = bool
        } else {
            let string = try container.decode(String.self)
            switch string.uppercased() {
            case "TRUE": wrappedValue = true
            case "FALSE": wrappedValue = false
            default:
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid boolean string: \(string)")
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
