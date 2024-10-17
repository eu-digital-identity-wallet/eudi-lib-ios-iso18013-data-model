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

public struct KeyInfo: Sendable {
    /// public key data in x963 representation
    public var publicKey: [UInt8]?
    /// Tasks for which key can be used.
    public var keyPurpose: [KeyPurpose] = KeyPurpose.allCases
    /// The chain of X.509 certificates, which can be used to verify the properties of that key pair.
    public var attestation: [[UInt8]]?
}
