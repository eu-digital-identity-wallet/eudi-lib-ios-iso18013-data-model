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

//  ClaimsDecodable.swift

import Foundation
import SwiftCBOR

/// A conforming type represents claims data.
///
/// Can be decoded by CBOR or SD-JWT data
public protocol DocClaimsDecodable: Sendable, AgeAttesting {
	/// The unique identifier of the document.
	var id: String { get }
	/// The date and time the document was created.
	var createdAt: Date { get }
	/// The date and time the document was last modified.
	var modifiedAt: Date? { get }
	/// The display name of the document (derived from `display`).
	var displayName: String? { get }
    /// The display properties of the document
    var display: [DisplayMetadata]? { get }
    /// The display properties of the issuer
    var issuerDisplay: [DisplayMetadata]? { get }
    /// The credential issuer identifier
    var credentialIssuerIdentifier: String? { get }
    /// The issuer configuration identifier
    var configurationIdentifier: String? { get }
	// The document type. For CBOR (mso_mdoc) documents is native, for SD-JWT (vc+sd-jwt) documents is the type of the document.
	var docType: String? { get }
	// document claims in a format agnostic way
	var docClaims: [DocClaim] { get }
    /// The format of the document data.
    var docDataFormat: DocDataFormat { get }
    /// Valid from date
    var validFrom: Date? { get }
    /// Valid until date
    var validUntil: Date? { get }
    /// This identifier is used to check the status of the document.
    var statusIdentifier: StatusIdentifier? { get }
} // end protocol

/// Methods to extract CBOR values.
extension DocClaimsDecodable {

	public static func getCborItemValue<T>(_ issuerSigned: IssuerSigned, _ s: String) -> T? {
		let nameSpaceItems = Self.getCborSignedItems(issuerSigned)
		guard let nameSpaceItems else { return nil }
		return Self.getCborItemValue(nameSpaceItems, string: s)
	}

	static func getCborItemValue<T>(_ nameSpaceItems: [NameSpace: [IssuerSignedItem]], string name: String) -> T? {
		for (_,v) in nameSpaceItems {
			if let item = v.first(where: { name == $0.elementIdentifier }) { return item.getTypedValue() }
		}
		return nil
	}

	public static func getCborSignedItems(_ issuerSigned: IssuerSigned, _ ns: [NameSpace]? = nil) -> [String: [IssuerSignedItem]]? {
		guard var nameSpaces = issuerSigned.issuerNameSpaces?.nameSpaces else { return nil }
		if let ns { nameSpaces = nameSpaces.filter { ns.contains($0.key) } }
		return nameSpaces
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

	/// Extracts a CBOR value.
	///
	/// - Parameters:
	///   - name: The name associated with the CBOR value.
	///   - cborValue: The CBOR value to be processed.pa
	///   - bDebugDisplay: A boolean flag indicating whether to enable debug display.s
	///   - ns: The namespace associated with the CBOR value.
	///   - order: The order in which the value should be processed.
	///   - labels: A dictionary where the key is the elementIdentifier and the value is a string representing the label.
	/// - Returns: A `DocClaim` object containing the extracted display string or image.
    public static func extractCborClaim(_ name: String, _ path: [String], _ cborValue: CBOR, _ bDebugDisplay: Bool, _ namespace: NameSpace, _ order: Int, _ displayNames: [String:String]? = nil, _ mandatory: [String:Bool]? = nil) -> DocClaim {
		var stringValue = bDebugDisplay ? cborValue.debugDescription : cborValue.description
		let dt = cborValue.mdocDataValue ?? .string(stringValue)
		if name == "sex", let isex = Int(stringValue), isex <= 2 { stringValue = NSLocalizedString(isex == 1 ? "male" : "female", comment: "") }
        let isMandatory = mandatory?[name] ?? true
        var node = DocClaim(name: name, path: path, displayName: displayNames?[name], dataValue: dt, stringValue: stringValue, isOptional: !isMandatory, order: order, namespace: namespace)
		if case let .map(m) = cborValue {
			let innerJsonMap = CBOR.decodeDictionary(m, unwrap: false)
			for (o2,(k,v)) in innerJsonMap.enumerated() {
				guard let cv = v as? CBOR else { continue }
				let child: DocClaim = extractCborClaim(k, node.path + [k], cv, bDebugDisplay, namespace, o2, displayNames, mandatory)
                node.add(child: child)
			}
		} else if case let .array(a) = cborValue {
			let innerJsonArray = CBOR.decodeList(a, unwrap: false)
			for (o2,v) in innerJsonArray.enumerated() {
				guard let cv = v as? CBOR else { continue }
                let child = extractCborClaim("", node.path + [""], cv, bDebugDisplay, namespace, o2, displayNames, mandatory)
				node.add(child: child)
			}
		}
		return node
	}

	/// Extracts display strings and images from the provided namespaces and populates the given arrays.
	///
	/// - Parameters:
	///   - nameSpaces: A dictionary where the key is a `NameSpace` and the value is an array of `IssuerSignedItem`.
	///   - docClaims: An inout parameter that will be populated with `DocClaim` items extracted from the namespaces.
	///   - displayNames: A namespaced dictionary where the key is the elementIdentifier and the value is a string representing the label.
    ///   - mandatory: A namespaced dictionary where the key is the elementIdentifier and the value is a boolean indicating whether the claim is mandatory.
	///   - nsFilter: An optional array of `NameSpace` to filter/sort the extraction. Defaults to `nil`.
	public static func extractCborClaims(_ nameSpaces: [NameSpace: [IssuerSignedItem]], _ docClaims: inout [DocClaim], _ displayNames: [NameSpace: [String: String]]?, _ mandatory: [NameSpace: [String: Bool]]?, nsFilter: [NameSpace]? = nil) {
		let bDebugDisplay = UserDefaults.standard.bool(forKey: "DebugDisplay")
		var order = 0
		let nsFilterUsed = nsFilter ?? Array(nameSpaces.keys)
		for ns in nsFilterUsed {
			let items = nameSpaces[ns] ?? []
			for item in items {
                let n = extractCborClaim(item.elementIdentifier, [ns, item.elementIdentifier],  item.elementValue, bDebugDisplay, ns, order, displayNames?[ns], mandatory?[ns])
				docClaims.append(n)
				order = order + 1
			}
		}
	}


} // end extension

