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


/// Key options
public struct KeyOptions: Sendable {
    public init(curve: CoseEcCurve = .P256, secureAreaName: String? = nil, accessProtection: KeyAccessProtection? = nil, accessControl: KeyAccessControl? = nil, keyPurposes: [KeyPurpose]? = KeyPurpose.allCases, additionalOptions: Data? = nil, credentialPolicy: CredentialPolicy, batchSize: Int) {
        self.curve = curve
        self.secureAreaName = secureAreaName
        self.accessProtection = accessProtection
        self.accessControl = accessControl
        self.keyPurposes = keyPurposes
        self.additionalOptions = additionalOptions
        self.credentialPolicy = credentialPolicy
        self.batchSize = batchSize
    }

    /// Cose EC curve
    public var curve: CoseEcCurve = .P256
    /// Secure are name
    public var secureAreaName: String?

    /// Key access protection options
    public var accessProtection: KeyAccessProtection?
    /// Key access control settings
    public var accessControl: KeyAccessControl?

    /// Key purposes
    public var keyPurposes: [KeyPurpose]? = KeyPurpose.allCases
    /// Any other additional option encoded value
    public var additionalOptions: Data?
    
    /// Allow reuse (use more than once)
    public var credentialPolicy: CredentialPolicy
    
    /// key batch size
    public var batchSize: Int
}

/// Tasks for which keys can be used.
public enum KeyPurpose: String, Codable, CaseIterable, Sendable {
    case signing = "Signing"
    case keyAgreement = "Key Agreement"
}

#if canImport(Security)
/// Key access protection options
///
/// You control an app’s access to a keychain item relative to the state of a device by setting the item’s kSecAttrAccessible attribute when you create the item.
public enum KeyAccessProtection: Int, CaseIterable, Sendable {
    /// Key data can only be accessed while the device is unlocked (default value).
    case whenUnlocked
    /// Key data can only be  accessed once the device has been unlocked after a restart.  This is  recommended for keys that need to be accesible by background applications.
    case afterFirstUnlock
    /// Key data can only be accessed while the device is unlocked. Key not restored from device backup.
    case whenUnlockedThisDeviceOnly
    /// Key data can only be  accessed once the device has been unlocked after a restart.  Key not restored from device backup.
    case afterFirstUnlockThisDeviceOnly
    /// Key data can only be accessed while the device is unlocked, requires a passcode to be set on the device.  Key not restored from device backup.
    case whenPasscodeSetThisDeviceOnly

    /// constant to use for the kSecAttrAccessible attribute
    public var constant: CFString {
        switch self {
        case .whenUnlocked: kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlock: kSecAttrAccessibleAfterFirstUnlock
        case .whenUnlockedThisDeviceOnly: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlockThisDeviceOnly: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .whenPasscodeSetThisDeviceOnly: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        }
    }
}
/// Key access control settings
///
/// Using these settings you can check for the presence of the authorized user at the very last minute before retrieving login credentials from the keychain. This helps secure the private key even if the user hands the device in an unlocked state to someone else.
public struct KeyAccessControl: OptionSet, Sendable {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    public let rawValue: Int

    /// Require user presence policy using biometry or Passcode
    public static let requireUserPresence = KeyAccessControl(rawValue: 1 << 0)
    /// Require application provided password for additional data encryption key generation
    public static let requireApplicationPassword = KeyAccessControl(rawValue: 1 << 1)

    public var flags: SecAccessControlCreateFlags {
        var result: SecAccessControlCreateFlags = []
        if contains(.requireUserPresence) { result.insert(.userPresence) }
        if contains(.requireApplicationPassword) { result.insert(.applicationPassword) }
        return result
    }
}
#endif
