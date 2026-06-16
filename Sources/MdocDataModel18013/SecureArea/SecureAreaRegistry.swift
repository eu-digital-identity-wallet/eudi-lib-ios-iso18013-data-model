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
import os

/// Registry for managing SecureArea implementations.
public final class SecureAreaRegistry:  Sendable {
    public enum DeviceSecureArea: String, CaseIterable {
        case secureEnclave = "SecureEnclave"
        case software = "Software"
    }
    private init() {}

    public static let shared = SecureAreaRegistry()
    private let secureAreasLock = OSAllocatedUnfairLock<[String: any SecureArea]>(uncheckedState: [:])

    public func register(secureArea: any SecureArea) {
        secureAreasLock.withLockUnchecked { secureAreas in
            secureAreas[type(of: secureArea).name] = secureArea
        }
    }

    public func get(name: String?) -> SecureArea {
        secureAreasLock.withLockUnchecked { secureAreas in
            if let name, let sa = secureAreas[name] { return sa }
            if let sa = secureAreas[DeviceSecureArea.secureEnclave.rawValue] { return sa }
            if let sa = secureAreas[DeviceSecureArea.software.rawValue] { return sa }
            return secureAreas.first!.value
        }
    }

    public func get(deviceSecureArea: DeviceSecureArea) -> SecureArea? {
        secureAreasLock.withLockUnchecked { secureAreas in
            secureAreas[deviceSecureArea.rawValue]
        }
    }

    public var names: [String] {
        secureAreasLock.withLockUnchecked { secureAreas in
            Array(secureAreas.keys)
        }
    }

    public var values: [any SecureArea] {
        secureAreasLock.withLockUnchecked { secureAreas in
            Array(secureAreas.values)
        }
    }

    public var defaultSecurityArea: (any SecureArea)? {
        secureAreasLock.withLockUnchecked { secureAreas in
            if let sa = secureAreas[DeviceSecureArea.secureEnclave.rawValue] {
                return sa
            } else if let sa = secureAreas[DeviceSecureArea.software.rawValue] {
                return sa
            } else {
                return secureAreas.first?.value
            }
        }
    }
}
