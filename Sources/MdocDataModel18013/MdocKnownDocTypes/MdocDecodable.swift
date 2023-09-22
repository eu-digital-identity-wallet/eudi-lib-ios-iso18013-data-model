//
//  MdocDecodable.swift

import Foundation

/// A conforming type represents mdoc data.
///
/// Can be decoded by a CBOR device response
public protocol MdocDecodable: AgeAttest {
	var response: DeviceResponse? { get set}
	var devicePrivateKey: CoseKeyPrivate? { get set}
	var docType: String { get set}
	var nameSpaces: [NameSpace]? { get set}
	var title: String { get set}
	var displayStrings: [NameValue] { get }
} // end protocol

extension MdocDecodable {
	
	public func getItemValue<T>(_ s: String) -> T? {
		guard let response else { return nil }
		let nameSpaceItems = Self.getSignedItems(response, docType)
		guard let nameSpaceItems else { return nil }
		return Self.getItemValue(nameSpaceItems, string: s)
	}
		
	static func getItemValue<T>(_ nameSpaceItems: [String: [IssuerSignedItem]], string s: String) -> T? {
		for (_,v) in nameSpaceItems {
			if let item = v.first(where: { s == $0.elementIdentifier }) { return item.getTypedValue() }
		}
		return nil
	}
	
	public static func getSignedItems(_ response: DeviceResponse, _ docType: String, _ ns: [NameSpace]? = nil) -> [String: [IssuerSignedItem]]? {
		guard let doc = response.documents?.findDoc(name: docType) else { return nil }
		guard var nameSpaces = doc.issuerSigned.issuerNameSpaces?.nameSpaces else { return nil }
		if let ns { nameSpaces = nameSpaces.filter { ns.contains($0.key) } }
		return nameSpaces
	}
	
	public static func extractAgeOverValues(_ nameSpaces: [String: [IssuerSignedItem]], _ ageOverXX: inout [Int: Bool]) {
		for (_, items) in nameSpaces {
			for item in items {
				let k = item.elementIdentifier
				if !k.hasPrefix("age_over_") { continue }
				if let age = Int(k.suffix(k.count - 9)) {
					let b: Bool? = item.getTypedValue()
					if let b { ageOverXX[age] = b }
				}
			}
		}
	}
		
	public static func extractDisplayStrings(_ nameSpaces: [String: [IssuerSignedItem]], _ displayStrings: inout [NameValue]) {
		let bDebugDisplay = UserDefaults.standard.bool(forKey: "DebugDisplay")
		var order = 0
		for (ns,items) in nameSpaces {
			for item in items {
				let name = item.elementIdentifier
				if name.hasPrefix("age_over_") { continue }
				var value = bDebugDisplay ? item.debugDescription : item.description
				if name == "sex", let isex = Int(value), isex <= 2 {
					value = NSLocalizedString(isex == 1 ? "male" : "female", comment: "")
				}
				if !bDebugDisplay, value.count == 0 { continue }
				displayStrings.append(NameValue(name: name, value: value, ns: ns, order: order))
				order = order + 1
			}
		}
	}
} // end extension
								
