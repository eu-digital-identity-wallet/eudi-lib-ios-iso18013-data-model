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

/// A piece of text in one language. Use a list of these for multi-language text.
public struct MultiLangString: Codable, Equatable, Sendable {
    public init(lang: String = "en", content: String) {
        self.lang = lang.isEmpty ? "en" : lang
        self.content = content
    }

    /// The language code.
    public let lang: String
    /// The text.
    public let content: String

    private enum CodingKeys: String, CodingKey {
        case lang
        case content
    }

    /// Some TS10 examples render this as a bare string instead of a `{lang, content}` object.
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let content = try? container.decode(String.self) {
            self.lang = "en"
            self.content = content
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lang = try container.decodeIfPresent(String.self, forKey: .lang) ?? "en"
        self.lang = lang.isEmpty ? "en" : lang
        self.content = try container.decode(String.self, forKey: .content)
    }
}
