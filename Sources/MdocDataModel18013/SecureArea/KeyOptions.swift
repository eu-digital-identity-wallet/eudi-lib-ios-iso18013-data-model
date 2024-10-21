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
import Security

/// Tasks for which keys can be used.
public enum KeyPurpose: String, CaseIterable, Sendable {
    case signing = "Signing"
    case keyAgreement = "Key Agreement"
}

/// Condition for the key to be available
///
/// When asking SecItemCopyMatching to return the key's data, the error errSecInteractionNotAllowed will be returned if the item's data is not available until a device unlock occurs.
public enum KeyAccessProtection: Int, CaseIterable, Sendable {
    case whenUnlocked
    case afterFirstUnlock
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlockThisDeviceOnly
    case whenPasscodeSetThisDeviceOnly
    
    // constant to use for the kSecAttrAccessible attribute
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

public struct KeyAccessControl {
    public var requireUserPresence: Bool = false
    public var requirePassword: Bool = false
    
    public var flags: SecAccessControlCreateFlags {
        switch (requirePassword, requireUserPresence) {
        case (false, false): []; case (false, true): [.userPresence]; case (true, false): [.applicationPassword] ; case (true, true): [.userPresence,.applicationPassword]
        }
    }
    
}
