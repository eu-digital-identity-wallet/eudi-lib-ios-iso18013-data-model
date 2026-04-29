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
    public init(display: [DisplayMetadata]?, isMandatory: Bool?, claimPath: [String], valueType: String?) {
        self.display = display
        self.isMandatory = isMandatory
        self.claimPath = claimPath
        self.valueType = valueType
}

	public func getDisplayName(_ uiCulture: String?) -> String? { display?.getName(uiCulture) }
	/// The type of the claim value, e.g. "string", "uint", "bool", "jpeg" etc.
	public let valueType: String?
	/// Display metadata for the claim, which may include localized names, descriptions, logos, etc.
	public let display: [DisplayMetadata]?
	/// Indicates whether the claim is mandatory or optional.
	public let isMandatory: Bool?
	/// The path to the claim value in the document, represented as an array of strings.
	public let claimPath: [String]
	/// Description of the claim.
	public var description: String { "\(claimPath)" }
	/// Debug description of the claim.
	public var debugDescription: String { "\(claimPath)" }
}
