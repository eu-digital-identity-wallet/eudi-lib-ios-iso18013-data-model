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

/// Codes a `Date` as an ISO 8601 string, e.g. `"2025-07-29T09:11:20Z"`.
@propertyWrapper
public struct ISO8601Coded: Codable, Equatable, Sendable {
    public var wrappedValue: Date

    public init(wrappedValue: Date) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = ISO8601DateFormatter().date(from: string) {
            wrappedValue = date
        } else if let date = Self.makeTimeZonelessFormatter().date(from: string) {
            wrappedValue = date
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO 8601 date: \(string)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(ISO8601DateFormatter().string(from: wrappedValue))
    }

    /// Some TS10 examples omit the timezone (e.g. `"2025-07-29T09:11:20"`); assume UTC in that case.
    private static func makeTimeZonelessFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }
}
