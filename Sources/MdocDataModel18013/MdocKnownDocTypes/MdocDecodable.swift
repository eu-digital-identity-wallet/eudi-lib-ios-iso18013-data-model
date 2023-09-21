//
//  MdocDecodable.swift

import Foundation

/// A conforming type represents mdoc data.
///
/// Can be decoded by a CBOR device response
public protocol MdocDecodable: AgeAttest {
	var response: DeviceResponse? { get }
	var devicePrivateKey: CoseKeyPrivate? { get }
	var docType: String { get }
	var title: String { get }
	var displayStrings: [NameValue] { get }
} // end protocol

extension MdocDecodable {
		
	static func getItemValue<T>(_ nameSpaces: [String: [IssuerSignedItem]], string s: String) -> T? {
		for (_,v) in nameSpaces {
			if let item = v.first(where: { s == $0.elementIdentifier }) { return item.getTypedValue() }
		}
		return nil
	}
	
	static func getSignedItems(_ response: DeviceResponse, _ docType: String) -> [String: [IssuerSignedItem]]? {
		guard let doc = response.documents?.findDoc(name: docType) else { return nil }
		guard let nameSpaces = doc.issuerSigned.issuerNameSpaces?.nameSpaces else { return nil }
		return nameSpaces
	}
	
	static func extractAgeOverValues(_ nameSpaces: [String: [IssuerSignedItem]], _ ageOverXX: inout [Int: Bool]) {
		for (ns,items) in nameSpaces {
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
		
	static func extractDisplayStrings(_ nameSpaces: [String: [IssuerSignedItem]], _ displayStrings: inout [NameValue]) {
		let bDebugDisplay = UserDefaults.standard.bool(forKey: "DebugDisplay")
		for (ns,items) in nameSpaces {
			for item in items {
				let name = item.elementIdentifier
				displayStrings.append(NameValue(name: name, value: bDebugDisplay ? item.debugDescription : item.description, ns: ns))
			}
		}
	}
} // end extension
								
