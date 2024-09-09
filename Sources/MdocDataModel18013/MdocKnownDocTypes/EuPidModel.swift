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

//  EuPidModel.swift

import Foundation

public struct EuPidModel: Codable, MdocDecodable {
	public var issuerSigned: IssuerSigned?
	public var devicePrivateKey: CoseKeyPrivate?
	public static var euPidDocType: String = "eu.europa.ec.eudi.pid.1" 
	public var id: String = UUID().uuidString
	public var createdAt: Date = Date()
	public var docType = Self.euPidDocType
	public var nameSpaces: [NameSpace]?
	public var displayName: String? = String("eu_pid_doctype_name")
	public var modifiedAt: Date?
	public var statusDescription: String?

	public let family_name: String?
	public let given_name: String?
	public let birth_date: String?
	public let family_name_birth: String?
	public let given_name_birth: String?
	public let birth_place: String?
	public let birth_country: String?
	public let birth_state: String?
	public let birth_city: String?
	public let resident_address: String?
	public let resident_city: String?
	public let resident_postal_code: String?
	public let resident_state: String?
	public let resident_country: String?
	public let resident_street: String?
	public let resident_house_number:String?
	public let gender: UInt64?
	public let nationality: String?
	public let age_in_years: UInt64?
	public let age_birth_year: UInt64?
	public let expiry_date: String?
	public let issuing_authority: String?
	public let issuance_date: String?
	public let document_number: String?
	public let administrative_number: String?
	public let issuing_country: String?
	public let issuing_jurisdiction: String?
	
	public enum CodingKeys: String, CodingKey, CaseIterable {
		case family_name
		case given_name
		case birth_date
		case family_name_birth
		case given_name_birth
		case birth_place
		case birth_country
		case birth_state
		case birth_city
		case resident_address
		case resident_city
		case resident_postal_code
		case resident_state
		case resident_country
		case resident_street
		case resident_house_number
		case gender
		case nationality
		case age_in_years
		case age_birth_year
		case expiry_date
		case issuing_authority
		case issuance_date
		case document_number
		case administrative_number
		case issuing_country
		case issuing_jurisdiction
	}
	static var mandatoryElementCodingKeys: [CodingKeys] {
		[.family_name, .given_name, .birth_date]
	}
	public var ageOverXX = [Int: Bool]()
	public var displayStrings = [NameValue]()
	public var displayImages = [NameImage]()
    public static var pidMandatoryElementKeys: [DataElementIdentifier] { ["age_over_18"] + mandatoryElementCodingKeys.map(\.rawValue) }
	public var mandatoryElementKeys: [DataElementIdentifier] { Self.pidMandatoryElementKeys }
}

extension EuPidModel {
	public init?(id: String, createdAt: Date, issuerSigned: IssuerSigned, devicePrivateKey: CoseKeyPrivate, displayName: String?, statusDescription: String?) {
		self.id = id
		self.createdAt = createdAt;	self.displayName = displayName; self.statusDescription = statusDescription
		self.issuerSigned = issuerSigned
		self.devicePrivateKey = devicePrivateKey
		guard let nameSpaces = Self.getSignedItems(issuerSigned, docType) else { return nil }
		Self.extractDisplayStrings(nameSpaces, &displayStrings, &displayImages)
		Self.extractAgeOverValues(nameSpaces, &ageOverXX)
		func getValue<T>(key: EuPidModel.CodingKeys) -> T? { Self.getItemValue(nameSpaces, string: key.rawValue) }
		family_name = getValue(key: .family_name)
		given_name = getValue(key: .given_name)
		birth_date = getValue(key: .birth_date)
		family_name_birth = getValue(key: .family_name_birth)
		given_name_birth = getValue(key: .given_name_birth)
		birth_place = getValue(key: .birth_place)
		birth_country = getValue(key: .birth_country)
		birth_state = getValue(key: .birth_state)
		birth_city = getValue(key: .birth_city)
		resident_address = getValue(key: .resident_address)
		resident_city = getValue(key: .resident_city)
		resident_postal_code = getValue(key: .resident_postal_code)
		resident_state = getValue(key: .resident_state)
		resident_country = getValue(key: .resident_country)
		resident_street = getValue(key: .resident_street)
		resident_house_number = getValue(key: .resident_house_number)
		gender = getValue(key: .gender)
		nationality = getValue(key: .nationality)
		age_in_years = getValue(key: .age_in_years)
		age_birth_year = getValue(key: .age_birth_year)
		expiry_date = getValue(key: .expiry_date)
		issuing_authority = getValue(key: .issuing_authority)
		issuance_date = getValue(key: .issuance_date)
		document_number = getValue(key: .document_number)
		administrative_number = getValue(key: .administrative_number)
		issuing_country = getValue(key: .issuing_country)
		issuing_jurisdiction = getValue(key: .issuing_jurisdiction)
	}
}
