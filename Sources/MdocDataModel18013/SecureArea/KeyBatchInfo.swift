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

public struct KeyBatchInfo: Codable, Sendable {
    
    public init(secureAreaName: String?, crv: CoseEcCurve, usedCounts: [Int], credentialPolicy: CredentialPolicy, keyPurpose: [KeyPurpose]? = nil, attestation: KeyAttestation? = nil) {
        self.secureAreaName = secureAreaName
        self.crv = crv
        self.usedCounts = usedCounts
        self.credentialPolicy = credentialPolicy
        self.keyPurpose = keyPurpose
        self.attestation = attestation
    }
    /// public key data
    public var crv: CoseEcCurve
    /// Tasks for which key can be used.
    public var keyPurpose: [KeyPurpose]? = KeyPurpose.allCases
    public var attestation: KeyAttestation?
    public let secureAreaName: String?
    public var usedCounts: [Int]
    public let credentialPolicy: CredentialPolicy

    public init?(from data: Data?) {
        guard let data else { return nil }
        do { self = try JSONDecoder().decode(KeyBatchInfo.self, from: data) }
        catch { return nil }
    }

    public func toData() -> Data? {
        do { return try JSONEncoder().encode(self) }
        catch { return nil }
    }
    
    public init(previous: KeyBatchInfo, keyIndex: Int) {
        self.secureAreaName = previous.secureAreaName
        self.crv = previous.crv
        self.credentialPolicy = previous.credentialPolicy
        var newUsedCounts = previous.usedCounts
        newUsedCounts[keyIndex] = previous.usedCounts[keyIndex] + 1
        self.usedCounts = newUsedCounts
        self.keyPurpose = previous.keyPurpose
        self.attestation = previous.attestation
   }

    public func findIndexToUse() -> Int? {
        guard let result = usedCounts.minWithIndexes() else { return nil }
        if result.value > 0, credentialPolicy == .oneTimeUse { return nil }
        return result.indexes.randomElement()
    }
    public var batchSize: Int { usedCounts.count }
}

public struct KeyAttestation: Codable, Sendable {
    // the key that the attestation is for.
    public var publicKey: CoseKey
    /// The chain of X.509 certificates in base64, which can be used to verify the properties of that key pair.
    public var attestation: [String]?
}
