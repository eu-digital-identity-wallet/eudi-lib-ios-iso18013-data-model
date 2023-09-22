//
//  NameValue.swift
import Foundation

public struct NameValue: Equatable, CustomStringConvertible {
	
	public init(name: String, value: String, ns: String? = nil, order: Int = 0) {
		self.name = name
		self.value = value
		self.ns = ns
		self.order = order
	}
	public let ns: String?
	public let name: String
	public var value: String
	public var order: Int = 0
	public var description: String { "\(name): \(value)" }
}
