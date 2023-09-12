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

//  MdocDecodable.swift

import Foundation

/// A conforming type represents mdoc data.
///
/// Can be decoded by a CBOR device response
public protocol MdocDecodable: AgeAttest {
	var response: DeviceResponse? { get }
	static var namespace: String { get }
	static var docType: String { get }
	static var title: String { get }
	var displayStrings: [NameValue] { get }
	init?(response: DeviceResponse)
}

extension MdocDecodable {
	static func getItemValue<T>(_ dict: [String: IssuerSignedItem], string s: String) -> T? {
		guard let item = dict[s] else { return nil }
		return item.getValue()
	}
	
	static func getSignedItems(_ response: DeviceResponse) -> ([IssuerSignedItem],[String: IssuerSignedItem])? {
		guard let items = response.documents?.findDoc(name: Self.docType)?.issuerSigned.issuerNameSpaces?[Self.namespace] else { return nil }
		let dict = Dictionary(grouping: items, by: { $0.elementIdentifier }).compactMapValues { $0.first }
		return (items, dict)
	}
	
	static func extractAgeOverValues(_ dict: [DataElementIdentifier : IssuerSignedItem], _ ageOverXX: inout [Int: Bool]) {
		let ageOverKeys = dict.keys.filter { $0.hasPrefix("age_over_")}
		for k in ageOverKeys {
			if let age = Int(k.suffix(k.count - 9)) {
				let b: Bool? = Self.getItemValue(dict, string: k)
				if let b { ageOverXX[age] = b }
			}
		}
	}
		
	static func extractDisplayStrings(_ items: [IssuerSignedItem], _ displayStrings: inout [NameValue]) {
		for item in items {
			let name = item.elementIdentifier
			displayStrings.append(NameValue(name: name, value: item.description))
		}
	}
}
								
