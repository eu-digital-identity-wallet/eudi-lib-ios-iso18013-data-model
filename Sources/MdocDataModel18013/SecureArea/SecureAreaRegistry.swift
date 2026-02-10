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

/// Registry for managing SecureArea implementations.
///
/// SAFETY INVARIANT (@unchecked Sendable):
/// This class is marked @unchecked Sendable because it contains mutable state (secureAreas dictionary)
/// that must be accessed from multiple threads. All access to the secureAreas dictionary is
/// protected by an NSLock to ensure thread-safe read and write operations.
/// The lock must be held for the entire duration of any operation that reads or modifies secureAreas.
public class SecureAreaRegistry: @unchecked Sendable {
    public enum DeviceSecureArea: String, CaseIterable {
        case secureEnclave = "SecureEnclave"
        case software = "Software"
    }
    private init() {}
    private let lock = NSLock()

    public static let shared = SecureAreaRegistry()
    private var secureAreas: [String: any SecureArea] = [:]

    public func register(secureArea: any SecureArea) {
        lock.lock()
        defer { lock.unlock() }
        secureAreas[type(of: secureArea).name] = secureArea
    }

    public func get(name: String?) -> SecureArea {
        lock.lock()
        defer { lock.unlock() }
        if let name, let sa = secureAreas[name] { return sa } else { return defaultSecurityArea! }
    }

    public func get(deviceSecureArea: DeviceSecureArea) -> SecureArea? {
        lock.lock()
        defer { lock.unlock() }
        return secureAreas[deviceSecureArea.rawValue]
    }

    public var names: [String] {
        lock.lock()
        defer { lock.unlock() }
        return Array(secureAreas.keys)
    }

    public var values: [any SecureArea] {
        lock.lock()
        defer { lock.unlock() }
        return Array(secureAreas.values)
    }

    public var defaultSecurityArea: (any SecureArea)? {
        lock.lock()
        defer { lock.unlock() }
        if let sa = secureAreas[DeviceSecureArea.secureEnclave.rawValue] {
            return sa
        } else if let sa = secureAreas[DeviceSecureArea.software.rawValue] {
            return sa
        } else {
            return secureAreas.first?.value
        }
    }
}
