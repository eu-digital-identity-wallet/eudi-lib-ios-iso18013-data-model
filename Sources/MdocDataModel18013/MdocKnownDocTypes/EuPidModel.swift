//
//  EuPidModel.swift


import Foundation

public struct EuPidModel: Codable, MdocDecodable {
	static let namespace = "eu.europa.ec.eudiw.pid.1"
	static let docType = "eu.europa.ec.eudiw.pid.1"
	
	public let family_name: String?
	public let family_name_national_characters: String?
	public let given_name: String?
	public let given_name_national_characters: String?
	public let birth_date: String?
	public let unique_id: String?
	public let wallet_pseudo_id: String?
	public let issuer_pseudo_id: String?
	public let anon_id: String?
	public let family_name_birth: String?
	public let family_name_birth_national_characters: String?
	public let given_name_birth: String?
	public let given_name_birth_national_characters: String?
	public let birth_place: String?
	public let resident_address: String?
	public let resident_city: String?
	public let resident_postal_code: String?
	public let resident_state: String?
	public let resident_country: String?
	public let gender: UInt64?
	public let nationality: String?
	public let age_in_years: UInt64?
	public let age_birth_year: UInt64?
	public let issue_date: String?
	public let expiry_date: String?
	public let issuing_authority: String?
	public let document_number: String?
	public let administrative_number: String?
	public let issuing_country: String?
	public let issuing_jurisdiction: String?
	
	public enum CodingKeys: String, CodingKey, CaseIterable {
		case family_name
		case family_name_national_characters
		case given_name
		case given_name_national_characters
		case birth_date
		case unique_id
		case wallet_pseudo_id
		case issuer_pseudo_id
		case anon_id
		case family_name_birth
		case family_name_birth_national_characters
		case given_name_birth
		case given_name_birth_national_characters
		case birth_place
		case resident_address
		case resident_city
		case resident_postal_code
		case resident_state
		case resident_country
		case gender
		case nationality
		case age_in_years
		case age_birth_year
		case issue_date
		case expiry_date
		case issuing_authority
		case document_number
		case administrative_number
		case issuing_country
		case issuing_jurisdiction
	}
	public var ageOverXX = [Int: Bool]()
	public var displayStrings = [NameValue]()
}

extension EuPidModel {
	init?(response: DeviceResponse) {
		guard let (items,dict) = Self.getSignedItems(response) else { return nil }
		func getValue<T>(key: EuPidModel.CodingKeys) -> T? { Self.getItemValue(dict, string: key.rawValue) }
		Self.extractAgeOverValues(dict, &ageOverXX)
		Self.extractDisplayStrings(items, &displayStrings)
		 family_name = getValue(key: .family_name)
		 family_name_national_characters = getValue(key: .family_name_national_characters)
		 given_name = getValue(key: .given_name)
		 given_name_national_characters = getValue(key: .given_name_national_characters)
		 birth_date = getValue(key: .birth_date)
		 unique_id = getValue(key: .unique_id)
		 wallet_pseudo_id = getValue(key: .wallet_pseudo_id)
		 issuer_pseudo_id = getValue(key: .issuer_pseudo_id)
		 anon_id = getValue(key: .anon_id)
		 family_name_birth = getValue(key: .family_name_birth)
		 family_name_birth_national_characters = getValue(key: .family_name_birth_national_characters)
		 given_name_birth = getValue(key: .given_name_birth)
		 given_name_birth_national_characters = getValue(key: .given_name_birth_national_characters)
		 birth_place = getValue(key: .birth_place)
		 resident_address = getValue(key: .resident_address)
		 resident_city = getValue(key: .resident_city)
		 resident_postal_code = getValue(key: .resident_postal_code)
		 resident_state = getValue(key: .resident_state)
		 resident_country = getValue(key: .resident_country)
		 gender = getValue(key: .gender)
		 nationality = getValue(key: .nationality)
		 age_in_years = getValue(key: .age_in_years)
		 age_birth_year = getValue(key: .age_birth_year)
		 issue_date = getValue(key: .issue_date)
		 expiry_date = getValue(key: .expiry_date)
		 issuing_authority = getValue(key: .issuing_authority)
		 document_number = getValue(key: .document_number)
		 administrative_number = getValue(key: .administrative_number)
		 issuing_country = getValue(key: .issuing_country)
		 issuing_jurisdiction = getValue(key: .issuing_jurisdiction)
	}
}
