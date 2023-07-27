//
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
								
