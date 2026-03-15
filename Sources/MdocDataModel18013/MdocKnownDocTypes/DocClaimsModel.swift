//
//  DocClaimsModel.swift

import Foundation

/// SAFETY INVARIANT (@unchecked Sendable):
/// This class is marked @unchecked Sendable because it contains a mutable property (credentialsUsageCounts)
/// that may be updated after initialization. Updates to this property must be performed by external code that ensures proper synchronization.
public class DocClaimsModel: DocClaimsDecodable, @unchecked Sendable, ObservableObject {
    public let display: [DisplayMetadata]?
    public let issuerDisplay: [DisplayMetadata]?
    public let credentialIssuerIdentifier: String?
    public let configurationIdentifier: String?
    public let validFrom: Date?
    internal let _validUntil: Date?
    public var validUntil: Date? { if let uc = credentialsUsageCounts, uc.remaining <= 0 { return nil } else { return _validUntil } }
    public let statusIdentifier: StatusIdentifier?
    @Published public var credentialsUsageCounts: CredentialsUsageCounts?
    public let credentialPolicy: CredentialPolicy
    public let secureAreaName: String?
	public let id: String
	public let createdAt: Date 
	public let docType: String
	public let displayName: String?
	public let modifiedAt: Date?
	public let ageOverXX: [Int: Bool]
	public let docClaims: [DocClaim]
    public let docDataFormat: DocDataFormat
    public let hashingAlg: String?
	public let nameSpaces: [NameSpace]?

    public init(configuration: DocClaimsModelConfiguration) {
        self.id = configuration.id
        self.createdAt = configuration.createdAt
        self.docType = configuration.docType
        self.displayName = configuration.displayName
        self.display = configuration.display
        self.issuerDisplay = configuration.issuerDisplay
        self.credentialIssuerIdentifier = configuration.credentialIssuerIdentifier
        self.configurationIdentifier = configuration.configurationIdentifier
        self.validFrom = configuration.validFrom
        self._validUntil = configuration.validUntil
        self.statusIdentifier = configuration.statusIdentifier
        self.secureAreaName = configuration.secureAreaName
        self.credentialsUsageCounts = configuration.credentialsUsageCounts
        self.credentialPolicy = configuration.credentialPolicy
        self.modifiedAt = configuration.modifiedAt
        self.ageOverXX = configuration.ageOverXX
        self.docClaims = configuration.docClaims
        self.docDataFormat = configuration.docDataFormat
        self.hashingAlg = configuration.hashingAlg
        self.nameSpaces = configuration.nameSpaces
    }

	public init?(configuration: DocClaimsModelConfiguration, issuerSigned: IssuerSigned, displayNames: [NameSpace: [String: String]]?, mandatory: [NameSpace: [String: Bool]]?) {
    self.id = configuration.id; self.createdAt = configuration.createdAt
        self.modifiedAt = nil
    self.displayName = configuration.displayName
    self.display = configuration.display; self.issuerDisplay = configuration.issuerDisplay
    self.credentialIssuerIdentifier = configuration.credentialIssuerIdentifier
     self.configurationIdentifier = configuration.configurationIdentifier
    self.validFrom = configuration.validFrom; self._validUntil = configuration.validUntil; self.statusIdentifier = configuration.statusIdentifier; self.secureAreaName = configuration.secureAreaName
    self.credentialsUsageCounts = configuration.credentialsUsageCounts
    self.credentialPolicy = configuration.credentialPolicy
    self.docType = configuration.docType
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

extension DocClaimsModel {
    public static let empty: DocClaimsModel = DocClaimsModel(
        configuration: DocClaimsModelConfiguration(
            docType: "",
            displayName: nil,
            display: nil,
            credentialIssuerIdentifier: nil,
            configurationIdentifier: nil,
            validFrom: nil,
            validUntil: nil,
            statusIdentifier: nil,
            credentialsUsageCounts: nil,
            credentialPolicy: .oneTimeUse,
            secureAreaName: nil,
            modifiedAt: nil,
            docClaims: [],
            docDataFormat: .cbor,
            hashingAlg: nil
        )
    )
}
