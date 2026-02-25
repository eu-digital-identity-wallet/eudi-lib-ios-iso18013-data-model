//
//  GenericMdocModel.swift

import Foundation

/// SAFETY INVARIANT (@unchecked Sendable):
/// This class is marked @unchecked Sendable because it contains a mutable property (credentialsUsageCounts)
/// that may be updated after initialization. Updates to this property must be performed by external code that ensures proper synchronization.
public class GenericMdocModel: DocClaimsDecodable, @unchecked Sendable {
    public let display: [DisplayMetadata]?
    public let issuerDisplay: [DisplayMetadata]?
    public let credentialIssuerIdentifier: String?
    public let configurationIdentifier: String?
    public let validFrom: Date?
    internal let _validUntil: Date?
    public var validUntil: Date? { if let uc = credentialsUsageCounts, uc.remaining <= 0 { return nil } else { return _validUntil } }
    public let statusIdentifier: StatusIdentifier?
    public var credentialsUsageCounts: CredentialsUsageCounts?
    public let credentialPolicy: CredentialPolicy
    public let secureAreaName: String?
	public let id: String
	public let createdAt: Date 
	public let docType: String?
	public let displayName: String?
	public let modifiedAt: Date?
	public let ageOverXX: [Int: Bool]
	public let docClaims: [DocClaim]
    public let docDataFormat: DocDataFormat
    public let hashingAlg: String?
	public let nameSpaces: [NameSpace]?

    public init(id: String = UUID().uuidString, createdAt: Date = Date(), docType: String?, displayName: String?, display: [DisplayMetadata]?, issuerDisplay: [DisplayMetadata]? = nil, credentialIssuerIdentifier: String?, configurationIdentifier: String?, validFrom: Date?, validUntil: Date?, statusIdentifier: StatusIdentifier?, credentialsUsageCounts: CredentialsUsageCounts?, credentialPolicy: CredentialPolicy, secureAreaName: String?, modifiedAt: Date?, ageOverXX: [Int : Bool], docClaims: [DocClaim], docDataFormat: DocDataFormat, hashingAlg: String?, nameSpaces: [NameSpace]?) {
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
        self.credentialPolicy = credentialPolicy
        self.modifiedAt = modifiedAt
        self.ageOverXX = ageOverXX
        self.docClaims = docClaims
        self.docDataFormat = docDataFormat
        self.hashingAlg = hashingAlg
        self.nameSpaces = nameSpaces
    }

	public init?(id: String, createdAt: Date, issuerSigned: IssuerSigned, docType: String, displayName: String?, display: [DisplayMetadata]?, issuerDisplay: [DisplayMetadata]?, credentialIssuerIdentifier: String?, configurationIdentifier: String?, validFrom: Date?, validUntil: Date?, statusIdentifier: StatusIdentifier?, credentialsUsageCounts: CredentialsUsageCounts?, credentialPolicy: CredentialPolicy, secureAreaName: String?, displayNames: [NameSpace: [String: String]]?, mandatory: [NameSpace: [String: Bool]]?) {
        self.id = id; self.createdAt = createdAt
        self.modifiedAt = nil
        self.displayName = displayName
        self.display = display; self.issuerDisplay = issuerDisplay
        self.credentialIssuerIdentifier = credentialIssuerIdentifier
         self.configurationIdentifier = configurationIdentifier
        self.validFrom = validFrom; self._validUntil = validUntil; self.statusIdentifier = statusIdentifier; self.secureAreaName = secureAreaName
        self.credentialsUsageCounts = credentialsUsageCounts
        self.credentialPolicy = credentialPolicy
        self.docType = docType
        self.docDataFormat = .cbor
        self.hashingAlg = nil
		if let nameSpaceItems = Self.getCborSignedItems(issuerSigned) {
            let extracted = Self.extractClaimsAndAgeValues(from: nameSpaceItems, displayNames: displayNames, mandatory: mandatory)
            self.nameSpaces = extracted.nameSpaces
            self.docClaims = extracted.docClaims
            self.ageOverXX = extracted.ageOverXX
		} else {
            self.nameSpaces = nil
            self.docClaims = [DocClaim]()
            self.ageOverXX = [Int: Bool]()
        }
	}

    static func extractClaimsAndAgeValues(from nameSpaceItems: [NameSpace: [IssuerSignedItem]], displayNames: [NameSpace: [String: String]]?, mandatory: [NameSpace: [String: Bool]]?) -> (docClaims: [DocClaim], ageOverXX: [Int: Bool], nameSpaces: [NameSpace]) {
        var docClaimsTemp = [DocClaim]()
        var ageOverXXtemp = [Int: Bool]()
        extractCborClaims(nameSpaceItems, &docClaimsTemp, displayNames, mandatory)
        extractAgeOverValues(nameSpaceItems, &ageOverXXtemp)
        let nameSpaces = Array(nameSpaceItems.keys)
        return (docClaimsTemp, ageOverXXtemp, nameSpaces)
    }
} 

