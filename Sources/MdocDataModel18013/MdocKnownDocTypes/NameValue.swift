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

//  NameValue.swift
import Foundation

/// Name-Value pair
public struct NameValue: Equatable, CustomStringConvertible, CustomDebugStringConvertible, Sendable {
	public init(name: String, value: String, ns: String? = nil, mdocDataType: MdocDataType? = nil, order: Int = 0, children: [NameValue]? = nil) {
		self.name = name
		self.value = value
		self.ns = ns
		self.mdocDataType = mdocDataType
		self.order = order
		self.children = children
	}
	public let ns: String?
	public let name: String
	public var value: String
	public var mdocDataType: MdocDataType?
	public var order: Int = 0
	public var children: [NameValue]?
	public var description: String { "\(name): \(value)" }
	public var debugDescription: String { "\(order). \(ns ?? ""): \(name) - \(value)" }

	public mutating func add(child: NameValue) {
		if children == nil { children = [] }
		children!.append(child)
	}
}