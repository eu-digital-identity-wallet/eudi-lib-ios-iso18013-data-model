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

public class SecureAreaRegistry: @unchecked Sendable {
    public enum DeviceSecureArea: String, CaseIterable {
        case secureEnclave = "SecureEnclave"
        case software = "Software"
    }
    private init() {}
    let lock = NSLock()
    
    public static let shared = SecureAreaRegistry()
    var secureAreas: [String: any SecureArea] = [:]
    
    public func register(secureArea: any SecureArea) {
        lock.lock()
        defer { lock.unlock() }
        secureAreas[type(of: secureArea).name] = secureArea
    }
    
    public func get(name: String?) -> SecureArea {
        if let name, let sa = secureAreas[name] { sa } else { defaultSecurityArea! }
    }
    
    public func get(deviceSecureArea: DeviceSecureArea) -> SecureArea? {
        secureAreas[deviceSecureArea.rawValue]
    }
    
    public var names: [String] { Array(secureAreas.keys) }
    public var defaultSecurityArea: (any SecureArea)? {
        get { get(deviceSecureArea: .secureEnclave) ?? get(deviceSecureArea: .software) }
    }
}
