//
//  DocClaimsModelConfiguration.swift

import Foundation

public struct DocClaimsModelConfiguration {
    public let id: String
    public let createdAt: Date
    public let docType: String
    public let displayName: String?
    public let display: [DisplayMetadata]?
    public let issuerDisplay: [DisplayMetadata]?
    public let credentialIssuerIdentifier: String?
    public let configurationIdentifier: String?
    public let validFrom: Date?
    public let validUntil: Date?
    public let statusIdentifier: StatusIdentifier?
    public let credentialsUsageCounts: CredentialsUsageCounts?
    public let credentialPolicy: CredentialPolicy
    public let secureAreaName: String?
    public let modifiedAt: Date?
    public let ageOverXX: [Int: Bool]
    public let docClaims: [DocClaim]
    public let docDataFormat: DocDataFormat
    public let hashingAlg: String?
    public let nameSpaces: [NameSpace]?

    public init(
        id: String = UUID().uuidString,
        createdAt: Date = Date(),
        docType: String,
        displayName: String?,
        display: [DisplayMetadata]?,
        issuerDisplay: [DisplayMetadata]? = nil,
        credentialIssuerIdentifier: String?,
        configurationIdentifier: String?,
        validFrom: Date?,
        validUntil: Date?,
        statusIdentifier: StatusIdentifier?,
        credentialsUsageCounts: CredentialsUsageCounts?,
        credentialPolicy: CredentialPolicy,
        secureAreaName: String?,
        modifiedAt: Date?,
        ageOverXX: [Int: Bool] = [:],
        docClaims: [DocClaim],
        docDataFormat: DocDataFormat,
        hashingAlg: String?,
        nameSpaces: [NameSpace]? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.docType = docType
        self.displayName = displayName
        self.display = display
        self.issuerDisplay = issuerDisplay
        self.credentialIssuerIdentifier = credentialIssuerIdentifier
        self.configurationIdentifier = configurationIdentifier
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.statusIdentifier = statusIdentifier
        self.credentialsUsageCounts = credentialsUsageCounts
        self.credentialPolicy = credentialPolicy
        self.secureAreaName = secureAreaName
        self.modifiedAt = modifiedAt
        self.ageOverXX = ageOverXX
        self.docClaims = docClaims
        self.docDataFormat = docDataFormat
        self.hashingAlg = hashingAlg
        self.nameSpaces = nameSpaces
    }
}
