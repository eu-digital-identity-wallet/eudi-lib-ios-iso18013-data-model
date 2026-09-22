/*
Copyright (c) 2026 European Commission

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

//  EuPidModel.swift

import Foundation

/// A model representing the claims of a European Personal Identification (EuPid) document, conforming to the ISO 18013-5 standard.
public final class EuPidModel: DocClaimsModel, @unchecked Sendable {
	public static let euPidDocType: String = "eu.europa.ec.eudi.pid.1"

	public let family_name: String?
	public let given_name: String?
	public let birth_date: String?
	public let place_of_birth: [String: String]?
	public let nationality: [String]?
	public let portrait: [UInt8]?
	public let resident_address: String?
	public let resident_country: String?
	public let resident_state: String?
	public let resident_city: String?
	public let resident_postal_code: String?
	public let resident_street: String?
	public let personal_administrative_number: String?
	public let family_name_birth: String?
	public let given_name_birth: String?
	public let sex: UInt64?
	public let email_address: String?
	public let mobile_phone_number: String?
	public let expiry_date: String?
	public let issuing_authority: String?
	public let issuing_country: String?
	public let document_number: String?
	public let issuing_jurisdiction: String?
	public let issuance_date: String?
	public let trust_anchor: String?
	public let attestation_legal_category: String?

	public enum CodingKeys: String, CodingKey, CaseIterable {
        case credentialIssuerIdentifier
        case configurationIdentifier

		case family_name
		case given_name
		case birth_date
		case place_of_birth
		case nationality
		case portrait
		case resident_address
		case resident_country
		case resident_state
		case resident_city
		case resident_postal_code
		case resident_street
		case personal_administrative_number
		case family_name_birth
		case given_name_birth
		case sex
		case email_address
		case mobile_phone_number
		case expiry_date
		case issuing_authority
		case issuing_country
		case document_number
		case issuing_jurisdiction
		case issuance_date
		case trust_anchor
		case attestation_legal_category
	}
	static var mandatoryElementCodingKeys: [CodingKeys] {
		[.family_name, .given_name, .birth_date, .place_of_birth, .nationality, .portrait, .issuing_authority, .issuing_country]
	}
	public static var pidMandatoryElementKeys: [DataElementIdentifier] { mandatoryElementCodingKeys.map(\.rawValue) }
	public var mandatoryElementKeys: [DataElementIdentifier] { Self.pidMandatoryElementKeys }

	public override init?(configuration: DocClaimsModelConfiguration, issuerSigned: IssuerSigned, displayNames: [NameSpace: [String: String]]?, mandatory: [NameSpace: [String: Bool]]?) {

        // Initialize properties specific to EuPidModel
		guard let nameSpaceItems = Self.getCborSignedItems(issuerSigned) else { return nil }
		func getValue<T>(key: EuPidModel.CodingKeys) -> T? { Self.getCborItemValue(nameSpaceItems, string: key.rawValue) }

		family_name = getValue(key: .family_name)
		given_name = getValue(key: .given_name)
		birth_date = getValue(key: .birth_date)
		place_of_birth = Self.getPlaceOfBirth(from: nameSpaceItems)
		nationality = getValue(key: .nationality)
		portrait = getValue(key: .portrait)
		resident_address = getValue(key: .resident_address)
		resident_country = getValue(key: .resident_country)
		resident_state = getValue(key: .resident_state)
		resident_city = getValue(key: .resident_city)
		resident_postal_code = getValue(key: .resident_postal_code)
		resident_street = getValue(key: .resident_street)
		personal_administrative_number = getValue(key: .personal_administrative_number)
		family_name_birth = getValue(key: .family_name_birth)
		given_name_birth = getValue(key: .given_name_birth)
		sex = getValue(key: .sex)
		email_address = getValue(key: .email_address)
		mobile_phone_number = getValue(key: .mobile_phone_number)
		expiry_date = getValue(key: .expiry_date)
		issuing_authority = getValue(key: .issuing_authority)
		issuing_country = getValue(key: .issuing_country)
		document_number = getValue(key: .document_number)
		issuing_jurisdiction = getValue(key: .issuing_jurisdiction)
		issuance_date = getValue(key: .issuance_date)
		trust_anchor = getValue(key: .trust_anchor)
		attestation_legal_category = getValue(key: .attestation_legal_category)

		let extracted = Self.extractClaimsAndAgeValues(from: nameSpaceItems, displayNames: displayNames, mandatory: mandatory)
        // Call superclass initializer
		super.init(
			configuration: DocClaimsModelConfiguration(
				id: configuration.id,
				createdAt: configuration.createdAt,
				docType: Self.euPidDocType,
				displayName: configuration.displayName ?? "eu_pid_doctype_name",
				display: configuration.display,
				issuerDisplay: configuration.issuerDisplay,
				credentialIssuerIdentifier: configuration.credentialIssuerIdentifier,
				configurationIdentifier: configuration.configurationIdentifier,
				validFrom: configuration.validFrom,
				validUntil: configuration.validUntil,
				statusList: configuration.statusList,
				credentialsUsageCounts: configuration.credentialsUsageCounts,
				credentialPolicy: configuration.credentialPolicy,
				secureAreaName: configuration.secureAreaName,
				modifiedAt: nil,
				ageOverXX: extracted.ageOverXX,
				docClaims: extracted.docClaims,
				docDataFormat: .cbor,
				hashingAlg: nil,
				nameSpaces: extracted.nameSpaces
			)
		)
	}

	private static func getPlaceOfBirth(from nameSpaceItems: [NameSpace: [IssuerSignedItem]]) -> [String: String]? {
		guard let item = nameSpaceItems.values
			.lazy
			.flatMap({ $0 })
			.first(where: { $0.elementIdentifier == CodingKeys.place_of_birth.rawValue }),
			case .map(let values) = item.elementValue
		else { return nil }

		let allowedKeys = Set(["country", "region", "locality"])
		let placeOfBirth = values.reduce(into: [String: String]()) { result, entry in
			guard case .utf8String(let key) = entry.key,
				allowedKeys.contains(key),
				case .utf8String(let value) = entry.value
			else { return }
			result[key] = value
		}
		return placeOfBirth.isEmpty ? nil : placeOfBirth
	}
}
