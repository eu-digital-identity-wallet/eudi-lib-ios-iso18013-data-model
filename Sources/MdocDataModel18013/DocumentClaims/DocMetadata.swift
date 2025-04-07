import Foundation

public struct DocMetadata: Sendable, Codable {
    /// document id
    public let docId: String
	/// the credential issuer identifier (issuer URL)
	public let credentialIssuerIdentifier: String
	/// the document configuration identifier
	public let configurationIdentifier: String
	/// the document type
	public let docType: String?
	/// get display name of the document for the given culture
	public func getDisplayName(_ uiCulture: String?) -> String? { display?.getName(uiCulture) }
	/// display properties for the document
	public let display: [DisplayMetadata]?
	/// display properties of the issuer that issued the document
	public let issuerDisplay: [DisplayMetadata]?
		/// get display name of the issuer for the given culture
	 public func getIssuerDisplayName(_ uiCulture: String?) -> String? { issuerDisplay?.getName(uiCulture) }

	/// namespaced claims (for sd-jwt documents)
	public let namespacedClaims: [NameSpace: [String: DocClaimMetadata]]?
	/// flat claims (for mso-mdoc documents)
	public let flatClaims: [String: DocClaimMetadata]?

	public init(docId: String, credentialIssuerIdentifier: String, configurationIdentifier: String, docType: String?, display: [DisplayMetadata]?, issuerDisplay: [DisplayMetadata]?, namespacedClaims: [NameSpace: [String: DocClaimMetadata]]? = nil, flatClaims: [String: DocClaimMetadata]? = nil) {
        self.docId = docId
		self.credentialIssuerIdentifier = credentialIssuerIdentifier
		self.configurationIdentifier = configurationIdentifier
		self.docType = docType
		self.display = display
		self.issuerDisplay = issuerDisplay
		self.namespacedClaims = namespacedClaims
		self.flatClaims = flatClaims
	}

	public init?(from data: Data?) {
		guard let data else { return nil }
		do { self = try JSONDecoder().decode(DocMetadata.self, from: data) }
		catch { return nil }
	}

	public func toData() -> Data? {
		do { return try JSONEncoder().encode(self) }
		catch { return nil }
	}
}

public struct DocClaimMetadata: Sendable, Codable {
    public init(display: [DisplayMetadata]?, isMandatory: Bool?, valueType: String? = nil) {
        self.display = display
        self.isMandatory = isMandatory
        self.valueType = valueType
    }

	public func getDisplayName(_ uiCulture: String?) -> String? { display?.getName(uiCulture) }
	public let display: [DisplayMetadata]?
	public let isMandatory: Bool?
	public let valueType: String?
}
