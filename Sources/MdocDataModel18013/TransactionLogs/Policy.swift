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

/// A reference to a policy document.
public struct Policy: Codable, Equatable, Sendable {
    public init(type: String, policyURI: String) {
        self.type = type
        self.policyURI = policyURI
    }

    /// URI of the policy type (e.g. ``privacyStatement``).
    public let type: String
    /// URL where the policy document is published.
    public let policyURI: String

    public static let trustServicePracticeStatement =
        "http://data.europa.eu/eudi/policy/trust-service-practice-statement"
    public static let termsAndConditions = "http://data.europa.eu/eudi/policy/terms-and-conditions"
    public static let privacyStatement = "http://data.europa.eu/eudi/policy/privacy-statement"
    public static let privacyPolicy = "http://data.europa.eu/eudi/policy/privacy-policy"
    public static let registrationPolicy = "http://data.europa.eu/eudi/policy/registration-policy"
}
