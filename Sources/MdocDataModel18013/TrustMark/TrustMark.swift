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

/// A wallet's Trust Mark configuration together with its downloaded resource.
public struct TrustMark: Codable, Equatable, Sendable {
	public let information: TrustMarkInformation
	public let resource: TrustMarkResource

	public init(information: TrustMarkInformation, resource: TrustMarkResource) {
		self.information = information
		self.resource = resource
	}

	/// Resolves relative image paths against the configured resource endpoint.
	public var imageURL: URL? {
		guard !resource.image.url.isEmpty,
			let baseURL = URL(string: information.trustMarkResourceURL),
			let url = URL(string: resource.image.url, relativeTo: baseURL)?.absoluteURL,
			["https", "http"].contains(url.scheme?.lowercased() ?? ""),
			let host = url.host, !host.isEmpty else { return nil }
		return url
	}
}
