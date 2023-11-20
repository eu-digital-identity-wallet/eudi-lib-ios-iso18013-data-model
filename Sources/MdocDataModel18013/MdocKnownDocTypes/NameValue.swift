 /*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */

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
