//
//  IsoMdlModel.swift

import Foundation

public struct IsoMdlModel: Decodable, AgeAttest {
	let exp: Int?
	let iat: Int?
	public let familyName: String?
	public let givenName: String?
	public let birthDate: String?
	public let birthPlace: String?
	public let issueDate: String?
	public let expiryDate: String?
	public let issuingCountry: String?
	public let issuingAuthority: String?
	public let documentNumber: String?
	public let administrativeNumber: String?
	let drivingPrivileges: [DrivingPrivileges]?
	public let nationality: String?
	public let eyeColour: String?
	public let hairColour: String?
	public var height: Int?
	public var weight: Int?
	public var sex: Int?
	public let residentAddress: String?
	public let residentCountry: String?
	public let residentCity: String?
	public let residentState: String?
	public let residentPostalCode: String?
	public var ageInYears: Int?
	public var ageOverXX = [Int: Bool]()
	public let ageBirthYear: Int?
	public let portrait: String?
	public let unDistinguishingSign: String?
	public let issuingJurisdiction: String?
	let portraitCaptureDate: String?
	public let familyNameNationalCharacter: String?
	public let givenNameNationalCharacter: String?
	public let signatureUsualMark: String?
	public let biometricTemplateFace: String?
	public let biometricTemplateSignatureSign: String?
	let webapiInfo: ServerRetrievalOption?
	let oidcInfo: ServerRetrievalOption?
	
	public enum CodingKeys: String, CodingKey, CaseIterable {
		case exp = "exp"
		case iat = "iat"
		case familyName = "family_name"
		case givenName = "given_name"
		case birthDate = "birth_date"
		case birthPlace = "birth_place"
		case issueDate = "issue_date"
		case expiryDate = "expiry_date"
		case issuingCountry = "issuing_country"
		case issuingAuthority = "issuing_authority"
		case documentNumber = "document_number"
		case administrativeNumber = "administrative_number"
		case drivingPrivileges = "driving_privileges"
		case unDistinguishingSign = "un_distinguishing_sign"
		case nationality = "nationality"
		case eyeColour = "eye_colour"
		case hairColour = "hair_colour"
		case height = "height"
		case weight = "weight"
		case sex = "sex" // uint
		case residentAddress = "resident_address"
		case residentCity = "resident_city"
		case residentState = "resident_state"
		case residentPostalCode = "resident_postal_code"
		case residentCountry = "resident_country"
		case ageInYears = "age_in_years"
		case ageBirthYear = "age_birth_year"
		case portrait = "portrait"
		case issuingJurisdiction = "issuing_jurisdiction"
		case portraitCaptureDate = "portrait_capture_date"
		case familyNameNationalCharacter = "family_name_national_character"
		case givenNameNationalCharacter = "given_name_national_character"
		case signatureUsualMark = "signature_usual_mark"
		case biometricTemplateFace = "biometric_template_face"
		case biometricTemplateSignatureSign = "biometric_template_signature_sign"
		case webapiInfo = "webapi_info"
		case oidcInfo = "oidc_info"
	}
	
	public static var namespace: String { "org.iso.18013.5.1" }
	
	public static var mandatoryKeys: [String] {
		Self.isoMandatoryKeys.map { $0.rawValue }
	}
	public static var isoMandatoryKeys: [CodingKeys] {
		[.familyName, .givenName, .birthDate, .issueDate, .expiryDate, .issuingCountry, .issuingAuthority, .documentNumber, .portrait, .drivingPrivileges, .unDistinguishingSign ]
	}
}
