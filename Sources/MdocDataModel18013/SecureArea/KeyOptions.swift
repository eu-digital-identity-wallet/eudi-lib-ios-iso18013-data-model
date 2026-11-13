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

/// Key options
public struct KeyOptions: Codable, Sendable, Equatable {
    public init(curve: CoseEcCurve = .P256, secureAreaName: String? = nil, accessProtection: KeyAccessProtection? = nil, accessControl: KeyAccessControl? = nil, keyPurposes: [KeyPurpose]? = KeyPurpose.allCases, additionalOptions: Data? = nil) {
        self.curve = curve
        self.secureAreaName = secureAreaName
        self.accessProtection = accessProtection
        self.accessControl = accessControl
        self.keyPurposes = keyPurposes
        self.additionalOptions = additionalOptions
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
public enum KeyAccessProtection: Int, Codable, CaseIterable, Sendable {
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
/// Codable conformance for the native flags, so ``KeyAccessControl`` can synthesise its own.
extension SecAccessControlCreateFlags: @retroactive Codable {}

/// Key access control settings
///
/// Using these settings you can check for the presence of the authorized user at the very last minute before retrieving login credentials from the keychain. This helps secure the private key even if the user hands the device in an unlocked state to someone else.
///
/// The named cases are mutually exclusive user authentication constraints. Use ``custom(_:)`` to pass any other
/// combination of keychain flags through verbatim, for example a biometry constraint with a passcode fallback:
/// `.custom([.biometryCurrentSet, .or, .devicePasscode])`.
public enum KeyAccessControl: Codable, Equatable, Sendable {
    // no access control
    case empty
    /// Require user presence policy using biometry or Passcode
    case requireUserPresence
    /// Require any enrolled biometry, without allowing passcode fallback
    case requireBiometryAny
    /// Require current biometry set without allowing passcode fallback or newly enrolled biometrics
    case requireBiometryCurrentSet
    /// Native keychain flags, used as given
    case custom(SecAccessControlCreateFlags)

    /// Creates the case matching the given native flags, falling back to ``custom(_:)`` for anything else
    public init(flags: SecAccessControlCreateFlags) {
        switch flags {
        case SecAccessControlCreateFlags.userPresence: self = .requireUserPresence
        case SecAccessControlCreateFlags.biometryAny: self = .requireBiometryAny
        case SecAccessControlCreateFlags.biometryCurrentSet: self = .requireBiometryCurrentSet
        default: self = .custom(flags)
        }
    }

    /// flags to use for the kSecAttrAccessControl attribute
    public var flags: SecAccessControlCreateFlags {
        switch self {
        case .empty: []
        case .requireUserPresence: SecAccessControlCreateFlags.userPresence
        case .requireBiometryAny: SecAccessControlCreateFlags.biometryAny
        case .requireBiometryCurrentSet: SecAccessControlCreateFlags.biometryCurrentSet
        case .custom(let flags): flags
        }
    }
}
#endif
