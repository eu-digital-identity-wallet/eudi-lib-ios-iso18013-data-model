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

/// Graphics and localized user information fetched from a Trust Mark resource endpoint.
public struct TrustMarkResource: Codable, Equatable, Sendable {
	public let image: Image
	public let text: Text

	public init(image: Image, text: Text) {
		self.image = image
		self.text = text
	}

	public struct Image: Codable, Equatable, Sendable {
		public let name: String
		/// Absolute URL or path relative to the Trust Mark resource URL.
		public let url: String

		public init(name: String, url: String) {
			self.name = name
			self.url = url
		}
	}

	public struct Text: Codable, Equatable, Sendable {
		public let name: String
		public let localisations: [String: String]

		public init(name: String, localisations: [String: String]) {
			self.name = name
			self.localisations = localisations
		}

		/// Matches a language tag, then its base language, English, or the first available language.
		public func localizedValue(for languageCode: String) -> String? {
			let tag = languageCode.replacingOccurrences(of: "_", with: "-").lowercased()
			let keys = localisations.keys.sorted()
			for candidate in [tag, String(tag.split(separator: "-").first ?? ""), "en"] {
				if let key = keys.first(where: { $0.replacingOccurrences(of: "_", with: "-").lowercased() == candidate }) {
					return localisations[key]
				}
			}
			return keys.first.flatMap { localisations[$0] }
		}
	}
}
