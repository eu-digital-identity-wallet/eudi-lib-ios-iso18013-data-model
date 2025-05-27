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

/// Represents key document usage
public struct KeyBatchUsage: Codable, Sendable {
    public init(secureAreaName: String?, batchSize: Int, allowReuse: Bool) {
        self.secureAreaName = secureAreaName
        self.batchSize = batchSize
        self.allowReuse = allowReuse
    }

    public let secureAreaName: String?
    public var batchSize: Int
    public let allowReuse: Bool

	public init?(from data: Data?) {
		guard let data else { return nil }
		do { self = try JSONDecoder().decode(KeyBatchUsage.self, from: data) }
		catch { return nil }
	}

	public func toData() -> Data? {
		do { return try JSONEncoder().encode(self) }
		catch { return nil }
	}
}

