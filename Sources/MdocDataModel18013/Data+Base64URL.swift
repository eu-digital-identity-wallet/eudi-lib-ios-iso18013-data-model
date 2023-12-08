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

extension Data {

/// init from local file
    public init?(name: String, ext: String = "json", from bundle:Bundle = Bundle.main) {
        guard let url = bundle.url(forResource: name, withExtension: ext) else { return nil }
        try? self.init(contentsOf: url, options: .mappedIfSafe)
    }

		public func decodeJSON<T: Decodable>(type: T.Type = T.self) -> T? {
        let decoder = JSONDecoder()
        guard let response = try? decoder.decode(type.self, from: self) else { return nil }
        return response
    }
    /// Decodes a base64-url encoded string to data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public init?(base64URLEncoded: String, options: Data.Base64DecodingOptions = []) {
        self.init(base64Encoded: base64URLEncoded.base64URLUnescaped(), options: options)
    }

    /// Decodes base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public init?(base64URLEncoded: Data, options: Data.Base64DecodingOptions = []) {
        self.init(base64Encoded: base64URLEncoded.base64URLUnescaped(), options: options)
    }

    /// Encodes data to a base64-url encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    ///
    /// - parameter options: The options to use for the encoding. Default value is `[]`.
    /// - returns: The base64-url encoded string.
    public func base64URLEncodedString(options: Data.Base64EncodingOptions = []) -> String {
        return base64EncodedString(options: options).base64URLEscaped()
    }

    /// Encodes data to base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    ///
    /// - parameter options: The options to use for the encoding. Default value is `[]`.
    /// - returns: The base64-url encoded data.
    public func base64URLEncodedData(options: Data.Base64EncodingOptions = []) -> Data {
        return base64EncodedData(options: options).base64URLEscaped()
    }
}

/// MARK: String Escape

extension String {
    /// Converts a base64-url encoded string to a base64 encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLUnescaped() -> String {
        let replaced = replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        /// https://stackoverflow.com/questions/43499651/decode-base64url-to-base64-swift
        let padding = replaced.count % 4
        if padding > 0 {
            return replaced + String(repeating: "=", count: 4 - padding)
        } else {
            return replaced
        }
    }

    /// Converts a base64 encoded string to a base64-url encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLEscaped() -> String {
        return replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    /// Converts a base64-url encoded string to a base64 encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public mutating func base64URLUnescape() {
        self = base64URLUnescaped()
    }

    /// Converts a base64 encoded string to a base64-url encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public mutating func base64URLEscape() {
        self = base64URLEscaped()
    }
}
extension UInt8 {
    public typealias Byte = UInt8
    /// -
    public static let hyphen: UInt8 = 0x2D
    /// +
    public static let plus: UInt8 = 0x2B
    /// _
    public static let underscore: UInt8 = 0x5F
    /// /
    public static let forwardSlash: Byte = 0x2F
    /// =
    public static let equals: Byte = 0x3D
}

/// MARK: Data Escape

extension Data {
    /// Converts base64-url encoded data to a base64 encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public mutating func base64URLUnescape() {
        for (i, byte) in enumerated() {
            switch byte {
            case .hyphen: self[i] = .plus
            case .underscore: self[i] = .forwardSlash
            default: break
            }
        }
        /// https://stackoverflow.com/questions/43499651/decode-base64url-to-base64-swift
        let padding = count % 4
        if padding > 0 {
            self += Data(repeating: .equals, count: 4 - count % 4)
        }
    }

    /// Converts base64 encoded data to a base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public mutating func base64URLEscape() {
        for (i, byte) in enumerated() {
            switch byte {
            case .plus: self[i] = .hyphen
            case .forwardSlash: self[i] = .underscore
            default: break
            }
        }
        self = split(separator: .equals).first ?? .init()
    }

    /// Converts base64-url encoded data to a base64 encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLUnescaped() -> Data {
        var data = self
        data.base64URLUnescape()
        return data
    }

    /// Converts base64 encoded data to a base64-url encoded data.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLEscaped() -> Data {
        var data = self
        data.base64URLEscape()
        return data
    }
}
