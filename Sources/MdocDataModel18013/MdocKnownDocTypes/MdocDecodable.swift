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
#if canImport(UIKit)
import UIKit
#endif

/// A conforming type represents mdoc data.
///
/// Can be decoded by a CBOR device response
public protocol MdocDecodable: DocumentProtocol, AgeAttesting {
	var issuerSigned: IssuerSigned? { get set}
	var devicePrivateKey: CoseKeyPrivate? { get set}
	var nameSpaces: [NameSpace]? { get set}
	var mandatoryElementKeys: [DataElementIdentifier] { get}
	var displayStrings: [NameValue] { get }
	var displayImages: [NameImage] { get }
	func toJson(base64: Bool) -> [String: Any]
} // end protocol

extension MdocDecodable {
	
	public func getItemValue<T>(_ s: String) -> T? {
		guard let issuerSigned else { return nil }
		let nameSpaceItems = Self.getSignedItems(issuerSigned, docType)
		guard let nameSpaceItems else { return nil }
		return Self.getItemValue(nameSpaceItems, string: s)
	}
		
	static func getItemValue<T>(_ nameSpaceItems: [NameSpace: [IssuerSignedItem]], string s: String) -> T? {
		for (_,v) in nameSpaceItems {
			if let item = v.first(where: { s == $0.elementIdentifier }) { return item.getTypedValue() }
		}
		return nil
	}
	
	public static func getSignedItems(_ issuerSigned: IssuerSigned, _ docType: String, _ ns: [NameSpace]? = nil) -> [String: [IssuerSignedItem]]? {
		guard var nameSpaces = issuerSigned.issuerNameSpaces?.nameSpaces else { return nil }
		if let ns { nameSpaces = nameSpaces.filter { ns.contains($0.key) } }
		return nameSpaces
	}
	
	public func toJson(base64: Bool = false) -> [String: Any] {
		guard let issuerSigned, let nameSpaceItems = Self.getSignedItems(issuerSigned, docType) else { return [:] }
		return nameSpaceItems.mapValues { $0.toJson(base64: base64) }
	}

	/// Extracts age-over values from the provided namespaces and updates the given dictionary with the results.
	///
	/// - Parameters:
	///   - nameSpaces: A dictionary where the key is a `NameSpace` and the value is an array of `IssuerSignedItem`.	
	///   - ageOverXX: An inout parameter that is a dictionary where the key is an integer representing the age and the value is a boolean indicating whether the age condition is met.
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
	
	/// Determines if there are more than two age-over element identifiers in the provided list.
	///
	/// - Parameters:
	///   - reqDocType: The required document type.	
	///   - reqNamespace: The required namespace.pa	
	///   - ageAttest: An instance conforming to the `AgeAttesting` protocol.s	
	///   - reqElementIdentifiers: A list of data element identifiers.	
	/// - Returns: A set of strings representing the identifiers that meet the criteria.		}

	public static func moreThan2AgeOverElementIdentifiers(_ reqDocType: DocType, _ reqNamespace: NameSpace, _ ageAttest: any AgeAttesting, _ reqElementIdentifiers: [DataElementIdentifier]) -> Set<String> {
		// special case for maximum two age_over_NN data elements shall be returned
		guard reqDocType == IsoMdlModel.isoDocType, reqNamespace == IsoMdlModel.isoNamespace else { return Set() }
		let ages =	reqElementIdentifiers.filter { $0.hasPrefix("age_over_")}.compactMap { k in Int(k.suffix(k.count - 9)) }
		let agesDict = ageAttest.max2AgesOver(ages: ages)
		return Set(	agesDict.filter { $1 == false }.keys.map { "age_over_\($0)" })
	}
		
	/// Extracts a display string or image from a CBOR value.
	/// 
	/// - Parameters:
	///   - name: The name associated with the CBOR value.	
	///   - cborValue: The CBOR value to be processed.pa	
	///   - bDebugDisplay: A boolean flag indicating whether to enable debug display.s	
	///   - displayImages: An inout array of `NameImage` to store the extracted images.	
	///   - ns: The namespace associated with the CBOR value.	
	///   - order: The order in which the value should be processed.	
	///   - labels: A dictionary where the key is the elementIdentifier and the value is a string representing the label. 
	/// - Returns: A `NameValue` object containing the extracted display string or image.		
	public static func extractDisplayStringOrImage(_ name: String, _ cborValue: CBOR, _ bDebugDisplay: Bool, _ displayImages: inout [NameImage], _ ns: NameSpace, _ order: Int, _ labels: [String: String]? = nil) -> NameValue {
		var value = bDebugDisplay ? cborValue.debugDescription : cborValue.description
		var dt = cborValue.mdocDataType
		if name == "sex", let isex = Int(value), isex <= 2 {
			value = NSLocalizedString(isex == 1 ? "male" : "female", comment: ""); dt = .string
		}
		if case let .byteString(bs) = cborValue {
			var encodeAsBase64 = name == "user_pseudonym"
			#if os(iOS) 
			if UIImage(data: Data(bs)) == nil { encodeAsBase64 = true }
			#endif
			if encodeAsBase64 {
				value = Data(bs).base64EncodedString()
			} else {
				displayImages.append(NameImage(name: labels?[name] ?? name, image: Data(bs), ns: ns))
			}
		}
		var node = NameValue(name: labels?[name] ?? name, value: value, ns: ns, mdocDataType: dt, order: order)
		if case let .map(m) = cborValue {
			let innerJsonMap = CBOR.decodeDictionary(m, unwrap: false)
			for (o2,(k,v)) in innerJsonMap.enumerated() {
				guard let cv = v as? CBOR else { continue }
				node.add(child: extractDisplayStringOrImage(k, cv, bDebugDisplay, &displayImages, ns, o2, labels))
			}
		} else if case let .array(a) = cborValue {
			let innerJsonArray = CBOR.decodeList(a, unwrap: false)
			for (o2,v) in innerJsonArray.enumerated() {
				guard let cv = v as? CBOR else { continue }
				let k = "\(name)[\(o2)]"
				node.add(child: extractDisplayStringOrImage(k, cv, bDebugDisplay, &displayImages, ns, o2, labels))
			}
		}
		return node
	}
	
	/// Extracts display strings and images from the provided namespaces and populates the given arrays.
	///
	/// - Parameters:
	///   - nameSpaces: A dictionary where the key is a `NameSpace` and the value is an array of `IssuerSignedItem`.
	///   - displayStrings: An inout parameter that will be populated with `NameValue` items extracted from the namespaces.
	///   - displayImages: An inout parameter that will be populated with `NameImage` items extracted from the namespaces.
	///   - labels: A dictionary where the key is the elementIdentifier and the value is a string representing the label. 
	///   - nsFilter: An optional array of `NameSpace` to filter/sort the extraction. Defaults to `nil`.
	public static func extractDisplayStrings(_ nameSpaces: [NameSpace: [IssuerSignedItem]], _ displayStrings: inout [NameValue], _ displayImages: inout [NameImage], _ labels: [String: String]? = nil, _ nsFilter: [NameSpace]? = nil) {
		let bDebugDisplay = UserDefaults.standard.bool(forKey: "DebugDisplay")
		var order = 0
		let nsFilterUsed = nsFilter ?? Array(nameSpaces.keys)
		for ns in nsFilterUsed {
			let items = nameSpaces[ns] ?? []
			for item in items {
				let n = extractDisplayStringOrImage(item.elementIdentifier, item.elementValue, bDebugDisplay, &displayImages, ns, order, labels)
				displayStrings.append(n)
				order = order + 1
			}
		}
	}

	
} // end extension
								
