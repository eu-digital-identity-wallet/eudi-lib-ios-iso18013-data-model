//
//  EuPidModel.swift


import Foundation

public struct EuPidModel: Codable, MdocDecodable {
	public static let namespace = "eu.europa.ec.eudiw.pid.1"
	public static let docType = "eu.europa.ec.eudiw.pid.1"
	public static let title = String.LocalizationValue("eu_pid_doctype_name")
	
	public let family_name: String?
	public let given_name: String?
	public let birth_date: String?
	public let unique_id: String?
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
		case unique_id
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
	public var ageOverXX = [Int: Bool]()
	public var displayStrings = [NameValue]()
}

extension EuPidModel {
	public init?(response: DeviceResponse) {
		guard let (items,dict) = Self.getSignedItems(response) else { return nil }
		func getValue<T>(key: EuPidModel.CodingKeys) -> T? { Self.getItemValue(dict, string: key.rawValue) }
		Self.extractAgeOverValues(dict, &ageOverXX)
		Self.extractDisplayStrings(items, &displayStrings)
		family_name = getValue(key: .family_name)
		given_name = getValue(key: .given_name)
		birth_date = getValue(key: .birth_date)
		unique_id = getValue(key: .unique_id)
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