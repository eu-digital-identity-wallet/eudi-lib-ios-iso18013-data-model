//
//  NameValue.swift
import Foundation

public struct NameValue: Equatable, CustomStringConvertible {
	
	public init(name: String, value: String) {
		self.name = name
		self.value = value
	}
	
	public let name: String
	public let value: String
	public var description: String { "\(name): \(value)" }
}
