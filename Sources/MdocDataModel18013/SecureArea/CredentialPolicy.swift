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

public enum CredentialPolicy: Codable, Sendable {
    /**
     * Policy that deletes the credential after a single use.
     *
     * This policy ensures credentials cannot be reused, providing enhanced security
     * by minimizing the timeframe during which credentials are available in the system.
     * It's particularly suitable for high-security scenarios where credential replay
     * attacks are a concern.
    */
    case oneTimeUse
    /**
     * Policy that manages credential rotation by tracking usage count.
     *
     * When a credential is used, its usage count is incremented, allowing the system
     * to distribute load across multiple available credentials. This approach balances
     * security with performance considerations by enabling credential reuse while
     * maintaining usage patterns for auditing and optimization purposes.
     *
     * Appropriate for scenarios requiring frequent authentication where the
     * performance overhead of continuous credential generation would be prohibitive.
     */
    case rotateUse
}