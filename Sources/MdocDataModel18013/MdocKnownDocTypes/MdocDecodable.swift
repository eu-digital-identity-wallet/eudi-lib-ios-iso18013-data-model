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
import SwiftCBOR

/// A conforming type represents mdoc data.
///
/// Can be decoded by a CBOR device response
public protocol MdocDecodable: AgeAttesting {
	var response: DeviceResponse? { get set}
	var devicePrivateKey: CoseKeyPrivate? { get set}
	var docType: String { get set}
	var nameSpaces: [NameSpace]? { get set}
	var title: String { get set}
	var mandatoryElementKeys: [DataElementIdentifier] { get}
	var displayStrings: [NameValue] { get }
	var displayImages: [NameImage] { get }
	func toJson() -> [String: Any]
} // end protocol

extension MdocDecodable {
	
	public func getItemValue<T>(_ s: String) -> T? {
		guard let response else { return nil }
		let nameSpaceItems = Self.getSignedItems(response, docType)
		guard let nameSpaceItems else { return nil }
		return Self.getItemValue(nameSpaceItems, string: s)
	}
		
	static func getItemValue<T>(_ nameSpaceItems: [NameSpace: [IssuerSignedItem]], string s: String) -> T? {
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
	
	public func toJson() -> [String: Any] {
		guard let response, let nameSpaceItems = Self.getSignedItems(response, docType) else { return [:] }
		return nameSpaceItems.mapValues { $0.toJson() }
	}
	
	public static func extractAgeOverValues(_ nameSpaces: [NameSpace: [IssuerSignedItem]], _ ageOverXX: inout [Int: Bool]) {
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
	
	public static func moreThan2AgeOverElementIdentifiers(_ reqDocType: DocType, _ reqNamespace: NameSpace, _ ageAttest: any AgeAttesting, _ reqElementIdentifiers: [DataElementIdentifier]) -> Set<String> {
		// special case for maximum two age_over_NN data elements shall be returned
		guard reqDocType == IsoMdlModel.isoDocType, reqNamespace == IsoMdlModel.isoNamespace else { return Set() }
		let ages =	reqElementIdentifiers.filter { $0.hasPrefix("age_over_")}.compactMap { k in Int(k.suffix(k.count - 9)) }
		let agesDict = ageAttest.max2AgesOver(ages: ages)
		return Set(	agesDict.filter { $1 == false }.keys.map { "age_over_\($0)" })
	}
		
	static func extractDisplayStrings(_ nameSpaces: [NameSpace: [IssuerSignedItem]], _ displayStrings: inout [NameValue], _ displayImages: inout [NameImage]) {
		let bDebugDisplay = UserDefaults.standard.bool(forKey: "DebugDisplay")
		var order = 0
		for (ns,items) in nameSpaces {
			for item in items {
				let name = item.elementIdentifier
				var value = bDebugDisplay ? item.debugDescription : item.description
				if name == "sex", let isex = Int(value), isex <= 2 {
					value = NSLocalizedString(isex == 1 ? "male" : "female", comment: "")
				}
				if case let .byteString(bs) = item.elementValue { displayImages.append(NameImage(name: name, image: Data(bs), ns: ns)) }
				//else if !bDebugDisplay, value.count == 0 { continue }
				var node = NameValue(name: name, value: value, ns: ns, order: order)
				if case let .map(m) = item.elementValue {
					let innerJson = CBOR.decodeDictionary(m)
					addJsonDict(innerJson, to: &node)
				}
				order = order + 1
				displayStrings.append(node)
			}
		}
	}
	
	static func addJsonDict(_ json: [String:Any], to: inout NameValue) {
		var order = 0
		for (k,v) in json {
			if let d = v as? [String:Any] {
				var n = NameValue(name: k, value: "")
				addJsonDict(d, to: &n)
				to.add(child: n)
			} else {
				to.add(child: NameValue(name: k, value: "\(v)", order: order))
				order = order + 1
			}
			
		}
	}
	
} // end extension
								
