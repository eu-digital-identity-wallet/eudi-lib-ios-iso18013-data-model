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
@testable import MdocDataModel18013
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif
#if canImport(Security)
import Security
#endif
import Foundation
import SwiftCBOR

public actor InMemoryP256SecureArea: SecureArea {
    
    var storage: any MdocDataModel18013.SecureKeyStorage
    var key: P256.Signing.PrivateKey!
    public nonisolated(unsafe) var x963Key: Data?
    
    init(storage: any MdocDataModel18013.SecureKeyStorage) {
        self.storage = storage
    }
    
    nonisolated public static func create(storage: any MdocDataModel18013.SecureKeyStorage) -> InMemoryP256SecureArea {
        InMemoryP256SecureArea(storage: storage)
    }
    
    public static var supportedEcCurves: [MdocDataModel18013.CoseEcCurve] { [.P256] }
    
    public func getStorage() async -> any MdocDataModel18013.SecureKeyStorage { storage }
    
    public func createKeyBatch(id: String, credentialOptions: CredentialOptions, keyOptions: KeyOptions?) async throws -> [CoseKey] {
        key = if let x963Key { try P256.Signing.PrivateKey(x963Representation: x963Key) } else { P256.Signing.PrivateKey() }
        guard SecKeyCreateWithData(key.x963Representation as NSData, [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom, kSecAttrKeyClass: kSecAttrKeyClassPrivate] as NSDictionary, nil) != nil else {  throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error creating private key"])  }
        return [CoseKey(crv: .P256, x963Representation: key.publicKey.x963Representation)]
    }
    
    public func getPublicKey(id: String, index: Int, curve: CoseEcCurve) async throws -> CoseKey {
        return CoseKey(crv: .P256, x963Representation: key.publicKey.x963Representation)
    }
    
    public func deleteKeyBatch(id: String, startIndex: Int, batchSize: Int) throws { }
    
    public func deleteKeyInfo(id: String) async throws {  }
    
    public func signature(id: String, index: Int, algorithm: MdocDataModel18013.SigningAlgorithm, dataToSign: Data, unlockData: Data?) throws -> Data {
        let signature = try key.signature(for: dataToSign)
        return signature.rawRepresentation
    }
    
    public func keyAgreement(id: String, index: Int, publicKey: MdocDataModel18013.CoseKey, unlockData: Data?) throws -> SharedSecret {
        let puk256 = try P256.KeyAgreement.PublicKey(x963Representation: publicKey.getx963Representation())
        let prk256 = try P256.KeyAgreement.PrivateKey(x963Representation: key.x963Representation)
        let sharedSecret = try prk256.sharedSecretFromKeyAgreement(with: puk256)
        return sharedSecret
        
    }
    
    public func getKeyBatchInfo(id: String) throws -> MdocDataModel18013.KeyBatchInfo {
        KeyBatchInfo(secureAreaName: Self.name, crv: .P256, usedCounts: [0], credentialPolicy: .rotateUse)
    }
}

public actor DummySecureKeyStorage: MdocDataModel18013.SecureKeyStorage {
    public func readKeyInfo(id: String) throws -> [String : Data] {
        [:]
    }
    
    public func readKeyData(id: String, index: Int) throws -> [String : Data] {
        [:]
    }
    
    public func writeKeyInfo(id: String, dict: [String : Data]) throws {  }
    
    public func writeKeyDataBatch(id: String, startIndex: Int, dicts: [[String: Data]], keyOptions: KeyOptions?) async throws { }
    
    public func deleteKeyBatch(id: String, startIndex: Int, batchSize: Int) throws { }
    
    public func deleteKeyInfo(id: String) async throws {  }
    
}

extension MdocDataModel18013.CoseKeyPrivate {
    // decode cbor string
    public init?(p256data base64: String) {
        guard let d = Data(base64Encoded: base64), let obj = try? CBOR.decode([UInt8](d)), let coseKey = try? CoseKey(cbor: obj), let cd = obj[-4], case let CBOR.byteString(rd) = cd else { return nil }
        let sampleSA = InMemoryP256SecureArea(storage: DummySecureKeyStorage())
        let keyData = NSMutableData(bytes: [0x04], length: [0x04].count)
        keyData.append(Data(coseKey.x)); keyData.append(Data(coseKey.y));  keyData.append(Data(rd))
        sampleSA.x963Key = keyData as Data
        self.init(secureArea: sampleSA)
    }
}
