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
	public init(name: String, displayName: String? = nil, docDataValue: DocDataValue? = nil, valueType: String? = nil, stringValue: String, isOptional: Bool = false, order: Int = 0, namespace: String? = nil, children: [DocClaim]? = nil) {
		self.name = name
        self.displayName = displayName
		self.docDataValue = docDataValue
        self.valueType = valueType
		self.stringValue = stringValue
        self.isOptional = isOptional
		self.order = order
		self.namespace = namespace
		self.children = children
	}
	public let namespace: String?
	public let name: String
    public let displayName: String?
	public let stringValue: String
	public let docDataValue: DocDataValue?
    public let valueType: String?
    public var isOptional: Bool = false
	public var order: Int = 0
	public var style: String?
	public var children: [DocClaim]?
	public var description: String { "\(name): \(stringValue)" }
	public var debugDescription: String { "\(order). \t\(name): \(stringValue)" }

	public mutating func add(child: DocClaim) {
		if children == nil { children = [] }
		children!.append(child)
	}
}
