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
	func toJson(base64: Bool) -> [String: Any]
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
	
	public func toJson(base64: Bool = false) -> [String: Any] {
		guard let response, let nameSpaceItems = Self.getSignedItems(response, docType) else { return [:] }
		return nameSpaceItems.mapValues { $0.toJson(base64: base64) }
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
		
	public static func extractDisplayStringOrImage(_ name: String, _ cborValue: CBOR, _ bDebugDisplay: Bool, _ displayImages: inout [NameImage], _ ns: NameSpace, _ order: Int) -> NameValue {
		var value = bDebugDisplay ? cborValue.debugDescription : cborValue.description
		var dt = cborValue.mdocDataType
		if name == "sex", let isex = Int(value), isex <= 2 {
			value = NSLocalizedString(isex == 1 ? "male" : "female", comment: ""); dt = .string
		}
		if case let .byteString(bs) = cborValue {
			displayImages.append(NameImage(name: name, image: Data(bs), ns: ns))
		}
		var node = NameValue(name: name, value: value, ns: ns, mdocDataType: dt, order: order)
		if case let .map(m) = cborValue {
			let innerJsonMap = CBOR.decodeDictionary(m, unwrap: false)
			for (o2,(k,v)) in innerJsonMap.enumerated() {
				guard let cv = v as? CBOR else { continue }
				node.add(child: extractDisplayStringOrImage(k, cv, bDebugDisplay, &displayImages, ns, o2))
			}
		} else if case let .array(a) = cborValue {
			let innerJsonArray = CBOR.decodeList(a, unwrap: false)
			for (o2,v) in innerJsonArray.enumerated() {
				guard let cv = v as? CBOR else { continue }
				let k = "\(name)[\(o2)]"
				node.add(child: extractDisplayStringOrImage(k, cv, bDebugDisplay, &displayImages, ns, o2))
			}
		}
		return node
	}
	
	public static func extractDisplayStrings(_ nameSpaces: [NameSpace: [IssuerSignedItem]], _ displayStrings: inout [NameValue], _ displayImages: inout [NameImage]) {
		let bDebugDisplay = UserDefaults.standard.bool(forKey: "DebugDisplay")
		var order = 0
		for (ns,items) in nameSpaces {
			for item in items {
				let n = extractDisplayStringOrImage(item.elementIdentifier, item.elementValue, bDebugDisplay, &displayImages, ns, order)
				displayStrings.append(n)
				order = order + 1
			}
		}
	}

	
} // end extension
								
