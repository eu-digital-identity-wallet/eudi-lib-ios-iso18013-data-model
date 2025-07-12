//
//  GenericMdocModel.swift

import Foundation

public class GenericMdocModel: DocClaimsDecodable, ObservableObject, @unchecked Sendable {
    public var display: [DisplayMetadata]?
    public var issuerDisplay: [DisplayMetadata]?
    public var credentialIssuerIdentifier: String?
    public var configurationIdentifier: String?
    public var validFrom: Date?
    internal var _validUntil: Date?
    public var validUntil: Date? { if let uc = credentialsUsageCounts, uc.remaining <= 0 { return nil } else { return _validUntil } }
    public var statusIdentifier: StatusIdentifier?
    @Published public var credentialsUsageCounts: CredentialsUsageCounts?
    public var secureAreaName: String?
	public var id: String = UUID().uuidString
	public var createdAt: Date = Date()
	public var docType: String?
	public var displayName: String?
	public var modifiedAt: Date?
	public var ageOverXX = [Int: Bool]()
	public var docClaims = [DocClaim]()
    public var docDataFormat: DocDataFormat
    public var hashingAlg: String?

    public init(id: String = UUID().uuidString, createdAt: Date = Date(), docType: String?, displayName: String?, display: [DisplayMetadata]?, issuerDisplay: [DisplayMetadata]? = nil, credentialIssuerIdentifier: String?, configurationIdentifier: String?, validFrom: Date?, validUntil: Date?, statusIdentifier: StatusIdentifier?, credentialsUsageCounts: CredentialsUsageCounts?, secureAreaName: String?, modifiedAt: Date?, ageOverXX: [Int : Bool] = [Int: Bool](), docClaims: [DocClaim] = [DocClaim](), docDataFormat: DocDataFormat, hashingAlg: String?) {
        self.id = id
        self.createdAt = createdAt
        self.docType = docType
        self.displayName = displayName
        self.display = display; self.issuerDisplay = issuerDisplay
        self.credentialIssuerIdentifier = credentialIssuerIdentifier
        self.configurationIdentifier = configurationIdentifier
        self.validFrom = validFrom
        self._validUntil = validUntil
        self.statusIdentifier = statusIdentifier
        self.secureAreaName = secureAreaName
        self.credentialsUsageCounts = credentialsUsageCounts
        self.modifiedAt = modifiedAt
        self.ageOverXX = ageOverXX
        self.docClaims = docClaims
        self.docDataFormat = docDataFormat
    }

	public init?(id: String, createdAt: Date, issuerSigned: IssuerSigned, docType: String, displayName: String?, display: [DisplayMetadata]?, issuerDisplay: [DisplayMetadata]?, credentialIssuerIdentifier: String?, configurationIdentifier: String?, validFrom: Date?, validUntil: Date?, statusIdentifier: StatusIdentifier?, credentialsUsageCounts: CredentialsUsageCounts?, secureAreaName: String?, displayNames: [NameSpace: [String: String]]?, mandatory: [NameSpace: [String: Bool]]?) {
        self.id = id; self.createdAt = createdAt; self.displayName = displayName
        self.display = display; self.issuerDisplay = issuerDisplay
        self.credentialIssuerIdentifier = credentialIssuerIdentifier; self.configurationIdentifier = configurationIdentifier
        self.validFrom = validFrom; self._validUntil = validUntil; self.statusIdentifier = statusIdentifier; self.secureAreaName = secureAreaName
        self.credentialsUsageCounts = credentialsUsageCounts
        self.docType = docType; self.docDataFormat = .cbor
		if let nameSpaces = Self.getCborSignedItems(issuerSigned) {
			Self.extractCborClaims(nameSpaces, &docClaims, displayNames, mandatory)
		}
	}
} // end extension
