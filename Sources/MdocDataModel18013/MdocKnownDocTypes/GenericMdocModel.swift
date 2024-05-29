//
//  GenericMdocModel.swift

import Foundation

public struct GenericMdocModel: MdocDecodable {
	public var id: String = UUID().uuidString
	public var createdAt: Date = Date()
 	public var issuerSigned: IssuerSigned?
	public var devicePrivateKey: CoseKeyPrivate?
	public var docType: String
	public var nameSpaces: [NameSpace]? 
	public var title: String
	public var ageOverXX = [Int: Bool]()
	public var displayStrings = [NameValue]()
	public var displayImages = [NameImage]()
    public var mandatoryElementKeys: [DataElementIdentifier] = []
}

extension GenericMdocModel {
	public init?(id: String, createdAt: Date, issuerSigned: IssuerSigned, devicePrivateKey: CoseKeyPrivate, docType: String, title: String) {
		self.id = id; self.createdAt = createdAt
		self.issuerSigned = issuerSigned; self.devicePrivateKey = devicePrivateKey; self.docType = docType; self.title = title
		guard let nameSpaces = Self.getSignedItems(issuerSigned, docType) else { return nil }
		Self.extractDisplayStrings(nameSpaces, &displayStrings, &displayImages)
	}
} // end extension
