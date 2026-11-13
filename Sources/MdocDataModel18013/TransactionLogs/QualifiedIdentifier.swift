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

/// An identifier in structured form: the scheme `type` as a URI and the bare `value`.
public struct QualifiedIdentifier: Codable, Equatable, Sendable {
    public init(type: String, value: String) {
        self.type = type
        self.value = value
    }

    /// The identifier scheme as a URI (for example ``LEI``, ``EUID``).
    public let type: String
    /// The bare identifier value.
    public let value: String

    private enum CodingKeys: String, CodingKey {
        case type
        case value = "identifier"
    }

    public static let eori = "http://data.europa.eu/eudi/id/EORI-No"
    public static let lei = "http://data.europa.eu/eudi/id/LEI"
    public static let euid = "http://data.europa.eu/eudi/id/EUID"
    public static let vatin = "http://data.europa.eu/eudi/id/VATIN"
    public static let tin = "http://data.europa.eu/eudi/id/TIN"
    public static let excise = "http://data.europa.eu/eudi/id/Excise"
}
