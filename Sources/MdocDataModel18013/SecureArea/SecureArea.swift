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
import CryptoKit

// Abstraction of a secure area for performing cryptographic operations
// 2 default iOS secure areas will be provided (keychain, software)
public protocol SecureArea: Actor {
    /// name of the secure area
    static var name: String { get }
    /// default Elliptic Curve type
    static var defaultEcCurve: CoseEcCurve { get }
    /// make key and return identifier
    func createKey(crv: CoseEcCurve, keyInfo: KeyInfo?) throws -> Data
    // delete key
    func deleteKey(keyTag: Data) throws
    // compute signature
    func signature(keyTag: Data, algorithm: SigningAlgorithm, dataToSign: Data, keyUnlockData: Data?) throws -> Data
    // make shared secret with other public key
    func keyAgreement(keyTag: Data, publicKey: Data, with curve: CoseEcCurve, keyUnlockData: Data?) throws -> SharedSecret
    // returns information about the key with the given key tag
    func getKeyInfo(keyTag: Data, keyUnlockData: Data?) throws -> KeyInfo
}

extension SecureArea {
    /// default Elliptic Curve type
    public static var defaultEcCurve: CoseEcCurve { .P256 }
    /// default name
    public static var name: String { String(describing: Self.self).replacingOccurrences(of: "SecureArea", with: "") }
}
