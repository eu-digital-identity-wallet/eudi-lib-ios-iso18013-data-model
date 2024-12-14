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

/// This structure is used to store and manage pairs of names and their corresponding values.
/// It provides functionality for comparing instances, generating string representations for
/// debugging and display purposes, and ensuring safe concurrent access.
@DebugDescription
public struct DocClaim: Equatable, CustomStringConvertible, CustomDebugStringConvertible, Sendable {
	public init(name: String, displayName: String? = nil, dataValue: DocDataValue? = nil, valueType: String? = nil, stringValue: String, isOptional: Bool = false, order: Int = 0, namespace: String? = nil, children: [DocClaim]? = nil) {
		self.name = name
        self.displayName = displayName
		self.dataValue = dataValue
        self.valueType = valueType
		self.stringValue = stringValue
        self.isOptional = isOptional
		self.order = order
		self.namespace = namespace
		self.children = children
	}
    /// The namespace of the claim (if document is a mso-mdoc)
	public let namespace: String?
    /// The name of the claim.
	public let name: String
    /// The display name of the claim, originated from VCI metadata/claims.
    public let displayName: String?
    /// The value of the claim as a string.
	public let stringValue: String
    /// The value of the claim as a `DocDataValue` (enum with associated values)
	public let dataValue: DocDataValue?
    /// The type of the value of the claim, originated from VCI metadata/claims.
    public let valueType: String?
    /// A flag indicating whether the claim is optional, originated from VCI metadata/claims.
    public var isOptional: Bool = false
    /// The order of the claim in the document.
	public var order: Int = 0
    /// A string for Wallet UI usage to define the style of the claim.
	public var style: String?
    /// The children of the claim.
	public var children: [DocClaim]?
    /// Description of the claim.
	public var description: String { "\(name): \(stringValue)" }
    /// Debug description of the claim.
	public var debugDescription: String { "\(order). \t\(name): \(stringValue)" }

    /// Adds a child to the claim.
	public mutating func add(child: DocClaim) {
		if children == nil { children = [] }
		children!.append(child)
	}
}
