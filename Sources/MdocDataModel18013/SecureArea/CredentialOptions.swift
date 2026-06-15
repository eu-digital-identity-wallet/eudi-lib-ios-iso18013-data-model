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

/// Credential options that can be used when creating credentials in the secure area. These options allow for fine-tuning the behavior of credential issuance and management.
/// If ARF Annex II policy is specified, any values passed will be overridden to comply with the policy requirements.
public struct CredentialOptions: Codable, Sendable {
    public init(
        credentialPolicy: CredentialPolicy,
        batchSize: Int,
        reissueTriggerUnused: Int? = nil,
        reissueTriggerLifetimeLeft: Int? = nil
    ) {
        self.credentialPolicy = credentialPolicy
        self.batchSize = batchSize
        self.reissueTriggerUnused = reissueTriggerUnused
        self.reissueTriggerLifetimeLeft = reissueTriggerLifetimeLeft
    }
    /// Allow reuse (use more than once)
    public var credentialPolicy: CredentialPolicy

    /// Key batch size
    public var batchSize: Int

    /// Reissue trigger threshold based on unused credentials in the batch.
    public var reissueTriggerUnused: Int?

    /// Reissue trigger threshold based on remaining credential lifetime.
    public var reissueTriggerLifetimeLeft: Int?
}
