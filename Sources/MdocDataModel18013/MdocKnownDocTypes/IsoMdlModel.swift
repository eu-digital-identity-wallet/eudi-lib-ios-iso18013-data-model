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

//  IsoMdlModel.swift

import Foundation

public struct IsoMdlModel: Decodable, MdocDecodable {
	public var id: String = UUID().uuidString
	public var createdAt: Date = Date()
	public var docType: String = Self.isoDocType
	public var nameSpaces: [NameSpace]?
	public var displayName: String? = String("mdl_doctype_name")
	public var modifiedAt: Date?
	public var statusDescription: String?
	public static var isoDocType: String { "org.iso.18013.5.1.mDL" }
	public static var isoNamespace: String { "org.iso.18013.5.1" }

	public var issuerSigned: IssuerSigned?
	public var devicePrivateKey: CoseKeyPrivate?
	let exp: UInt64?
	let iat: UInt64?
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
	public let drivingPrivileges: DrivingPrivileges?
	public let nationality: String?
	public let eyeColour: String?
	public let hairColour: String?
	public let height: UInt64?
	public let weight: UInt64?
	public let sex: UInt64?
	public let residentAddress: String?
	public let residentCountry: String?
	public let residentCity: String?
	public let residentState: String?
	public let residentPostalCode: String?
	public let ageInYears: UInt64?
	public var ageOverXX = [Int: Bool]()
	public var displayStrings = [NameValue]()
	public var displayImages = [NameImage]()
	public let ageBirthYear: UInt64?
	public let portrait: [UInt8]?
	public let unDistinguishingSign: String?
	public let issuingJurisdiction: String?
	public let portraitCaptureDate: String?
	public let familyNameNationalCharacter: String?
	public let givenNameNationalCharacter: String?
	public let signatureUsualMark: [UInt8]?
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

    public static var isoMandatoryElementKeys: [DataElementIdentifier] { Self.isoMandatoryKeys.map(\.rawValue ) }

	public static var isoMandatoryKeys: [CodingKeys] {
		[.familyName, .givenName, .birthDate, .issueDate, .expiryDate, .issuingCountry, .issuingAuthority, .documentNumber, .portrait, .drivingPrivileges, .unDistinguishingSign ]
	}
	public var mandatoryElementKeys: [DataElementIdentifier] { Self.isoMandatoryElementKeys }
}


extension IsoMdlModel {
	public init?(id: String, createdAt: Date, issuerSigned: IssuerSigned, devicePrivateKey: CoseKeyPrivate, displayName: String?, statusDescription: String?, nameSpaces: [NameSpace]? = nil) {
		self.id = id; self.createdAt = createdAt; self.displayName = displayName; self.statusDescription = statusDescription
		self.issuerSigned = issuerSigned; self.devicePrivateKey = devicePrivateKey; self.nameSpaces = nameSpaces
  	guard let nameSpaceItems = Self.getSignedItems(issuerSigned, docType, nameSpaces) else { return nil }
		Self.extractDisplayStrings(nameSpaceItems, &displayStrings, &displayImages)
		func getValue<T>(key: IsoMdlModel.CodingKeys) -> T? { Self.getItemValue(nameSpaceItems, string: key.rawValue) }
		Self.extractAgeOverValues(nameSpaceItems, &ageOverXX)
		exp = getValue(key: .exp)
		iat = getValue(key: .iat)
		familyName = getValue(key: .familyName)
		givenName = getValue(key: .givenName)
		birthDate = getValue(key: .birthDate)
		birthPlace = getValue(key: .birthPlace)
		issueDate = getValue(key: .issueDate)
		expiryDate = getValue(key: .expiryDate)
		issuingCountry = getValue(key: .issuingCountry)
		issuingAuthority = getValue(key: .issuingAuthority)
		documentNumber = getValue(key: .documentNumber)
		administrativeNumber = getValue(key: .administrativeNumber)
		drivingPrivileges = getValue(key: .drivingPrivileges)
		nationality = getValue(key: .nationality)
		eyeColour = getValue(key: .eyeColour)
		hairColour = getValue(key: .hairColour)
		height = getValue(key: .height)
		weight = getValue(key: .weight)
		sex = getValue(key: .sex)
		residentAddress = getValue(key: .residentAddress)
		residentCountry = getValue(key: .residentCountry)
		residentCity = getValue(key: .residentCity)
		residentState = getValue(key: .residentState)
		residentPostalCode = getValue(key: .residentPostalCode)
		ageInYears = getValue(key: .ageInYears)
		ageBirthYear = getValue(key: .ageBirthYear)
		portrait = getValue(key: .portrait)
		unDistinguishingSign = getValue(key: .unDistinguishingSign)
		issuingJurisdiction = getValue(key: .issuingJurisdiction)
		portraitCaptureDate = getValue(key: .portraitCaptureDate)
		familyNameNationalCharacter = getValue(key: .familyNameNationalCharacter)
		givenNameNationalCharacter = getValue(key: .givenNameNationalCharacter)
		signatureUsualMark = getValue(key: .signatureUsualMark)
		biometricTemplateFace = getValue(key: .biometricTemplateFace)
		biometricTemplateSignatureSign = getValue(key: .biometricTemplateSignatureSign)
		webapiInfo = getValue(key: .webapiInfo)
		oidcInfo = getValue(key: .oidcInfo)
	}
}
