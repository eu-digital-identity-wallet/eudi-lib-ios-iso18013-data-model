//
//  NameValue.swift
import Foundation

public struct NameValue: Equatable, CustomStringConvertible {
	
	public init(name: String, value: String, ns: String? = nil) {
		self.name = name
		self.value = value
		self.ns = ns
	}
	public let ns: String?
	public let name: String
	public var value: String
	public var description: String { "\(name): \(value)" }
}
