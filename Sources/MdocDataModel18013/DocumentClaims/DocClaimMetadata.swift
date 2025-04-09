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

@DebugDescription
public struct DocClaimMetadata: Sendable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
	public func getDisplayName(_ uiCulture: String?) -> String? { display?.getName(uiCulture) }
	public let display: [DisplayMetadata]?
	public let isMandatory: Bool?
	public let claimPath: [String]
	/// Description of the claim.
	public var description: String { "\(claimPath)" }
	/// Debug description of the claim.
	public var debugDescription: String { "\(claimPath)" }
}