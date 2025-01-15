//
//  GenericMdocModel.swift

import Foundation

public struct GenericMdocModel: DocClaimsDecodable, Sendable {
    public var display: [DisplayMetadata]?
    public var issuerDisplay: [DisplayMetadata]?
	public var id: String = UUID().uuidString
	public var createdAt: Date = Date()
	public var docType: String?
	public var displayName: String?
	public var modifiedAt: Date?
	public var ageOverXX = [Int: Bool]()
	public var docClaims = [DocClaim]()
    public var docDataFormat: DocDataFormat
    public var hashingAlg: String?

    public init(id: String = UUID().uuidString, createdAt: Date = Date(), docType: String? = nil, displayName: String? = nil, display: [DisplayMetadata]? = nil, issuerDisplay: [DisplayMetadata]? = nil, modifiedAt: Date? = nil, ageOverXX: [Int : Bool] = [Int: Bool](), docClaims: [DocClaim] = [DocClaim](), docDataFormat: DocDataFormat = .cbor, hashingAlg: String? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.docType = docType
        self.displayName = displayName
        self.display = display; self.issuerDisplay = issuerDisplay
        self.modifiedAt = modifiedAt
        self.ageOverXX = ageOverXX
        self.docClaims = docClaims
        self.docDataFormat = docDataFormat
    }
}

extension GenericMdocModel {

	public init?(id: String, createdAt: Date, issuerSigned: IssuerSigned, docType: String, displayName: String?, display: [DisplayMetadata]?, issuerDisplay: [DisplayMetadata]?, claimDisplayNames: [NameSpace: [String: String]]?, mandatoryClaims: [NameSpace: [String: Bool]]?, claimValueTypes: [NameSpace: [String: String]]?) {
        self.id = id; self.createdAt = createdAt; self.displayName = displayName
        self.display = display; self.issuerDisplay = issuerDisplay
        self.docType = docType; self.docDataFormat = .cbor
		if let nameSpaces = Self.getCborSignedItems(issuerSigned) {
			Self.extractCborClaims(nameSpaces, &docClaims, claimDisplayNames, mandatoryClaims, claimValueTypes)
		}
	}
} // end extension
