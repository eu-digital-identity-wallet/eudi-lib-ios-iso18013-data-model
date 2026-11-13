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

/// Which claims were requested or presented in a transaction.
///
/// Holds only which claims were involved, not their values.
public struct ClaimInfo: Codable, Equatable, Sendable {
    public init(credentialIdentifier: String, claims: [ClaimPath]) {
        self.credentialIdentifier = credentialIdentifier
        self.claims = claims
    }

    /// The credential the claims belong to; the `vct` value for SD-JWT VC or the `docType` value for ISO/IEC 18013-5.
    public let credentialIdentifier: String
    /// The claim paths involved. Each ``ClaimPath`` is one OpenID4VP §7 path pointer.
    public let claims: [ClaimPath]

    private enum CodingKeys: String, CodingKey {
        case credentialIdentifier
        case claims
    }

    /// Some TS10 examples render each claim as a bare name instead of a full path array.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        credentialIdentifier = try container.decode(String.self, forKey: .credentialIdentifier)
        var claimsContainer = try container.nestedUnkeyedContainer(forKey: .claims)
        var claims: [ClaimPath] = []
        while !claimsContainer.isAtEnd {
            if let name = try? claimsContainer.decode(String.self) {
                claims.append(.claim(name))
            } else {
                claims.append(try claimsContainer.decode(ClaimPath.self))
            }
        }
        self.claims = claims
    }
}
