//
//  NameValue.swift
import Foundation

public struct NameValue: Equatable, CustomStringConvertible {
	
	public init(name: String, value: String, ns: String?) {
		self.name = name
		self.value = value
		self.ns = ns
	}
	public let ns: String?
	public let name: String
	public let value: String
	public var description: String { "\(name): \(value)" }
}
