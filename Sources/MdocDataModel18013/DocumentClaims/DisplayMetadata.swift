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

public struct DisplayMetadata: Codable, Equatable, Sendable {
    public let name: String?
    public let localeIdentifier: String?
    public let logo: LogoMetadata?
    public let description: String?
    public let backgroundColor: String?
    public let textColor: String?
    public var locale: Locale? { Locale(identifier: localeIdentifier ?? "en_US") }
    
    public init(name: String? = nil, localeIdentifier: String? = nil, logo: LogoMetadata? = nil, description: String? = nil, backgroundColor: String? = nil, textColor: String? = nil) {
        self.name = name
        self.localeIdentifier = localeIdentifier
        self.logo = logo
        self.description = description
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
}