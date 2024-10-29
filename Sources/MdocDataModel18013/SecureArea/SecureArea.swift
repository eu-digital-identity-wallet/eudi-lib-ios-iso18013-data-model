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
#if canImport(CryptoKit)
import CryptoKit
#else 
import Crypto
#endif 
#if canImport(Security)
import Security
#endif 

// Abstraction of a secure area for performing cryptographic operations
// 2 default iOS secure areas will be provided (keychain, software)
public protocol SecureArea: Sendable {
    /// name of the secure area
    static var name: String { get }
    /// default Elliptic Curve type
    static var defaultEcCurve: CoseEcCurve { get }
    var storage: any SecureKeyStorage { get }
    init(storage: any SecureKeyStorage)
    /// make key and return key tag
    func createKey(id: String, keyOptions: KeyOptions?) throws -> (SecKey, CoseKey) 
    // delete key
    func deleteKey(id: String) throws
    // compute signature
    func signature(id: String, algorithm: SigningAlgorithm, dataToSign: Data, keyUnlockData: Data?) throws -> Data
    // make shared secret with other public key
    func keyAgreement(id: String, publicKey: CoseKey, keyUnlockData: Data?) throws -> SharedSecret
    // returns information about the key with the given key tag
    func getKeyInfo(id: String) throws -> KeyInfo
}

extension SecureArea {
    /// default Elliptic Curve type
    public static var defaultEcCurve: CoseEcCurve { .P256 }
    /// default name
    public static var name: String { String(describing: Self.self).replacingOccurrences(of: "SecureArea", with: "") }
}


