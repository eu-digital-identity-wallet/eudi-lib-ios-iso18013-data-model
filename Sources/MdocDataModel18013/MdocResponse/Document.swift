//
//  Document.swift

import Foundation
import SwiftCBOR

/// Contains a returned cocument. The document type of the returned document is indicated by the docType element.
public struct Document {
	
	public let docType: DocType
	public let issuerSigned: IssuerSigned
	public let deviceSigned: DeviceSigned? // todo: make mandatory
	/// error codes for data elements that are not returned
	public let errors: Errors?
	
	enum Keys:String {
		case docType
		case issuerSigned
		case deviceSigned
		case errors
	}
	
	public init(docType: DocType, issuerSigned: IssuerSigned, deviceSigned: DeviceSigned? = nil, errors: Errors? = nil) {
		self.docType = docType
		self.issuerSigned = issuerSigned
		self.deviceSigned = deviceSigned
		self.errors = errors
	}
}

extension Document: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case .map(let cd) = cbor else { return nil }
		guard case .utf8String(let dt) = cd[Keys.docType] else { return nil }
		docType = dt
		guard let cis = cd[Keys.issuerSigned], let `is` = IssuerSigned(cbor: cis) else { return nil }
		issuerSigned = `is`
		//guard let cds = cd[Keys.deviceSigned], let ds = DeviceSigned(cbor: cds) else { return nil }; deviceSigned = ds
		if let cds = cd[Keys.deviceSigned], let ds = DeviceSigned(cbor: cds) { deviceSigned = ds } else { deviceSigned = nil };
		if let ce = cd[Keys.errors], let e = Errors(cbor: ce) { errors = e} else { errors = nil }
	}
}

extension Document: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = [CBOR: CBOR]()
		cbor[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
		cbor[.utf8String(Keys.issuerSigned.rawValue)] = issuerSigned.toCBOR(options: options)
		if let dsign = deviceSigned { cbor[.utf8String(Keys.deviceSigned.rawValue)] = dsign.toCBOR(options: options) }
		if let errors { cbor[.utf8String(Keys.errors.rawValue)] = errors.toCBOR(options: options) }
		return .map(cbor)
	}
}

extension Array where Element == Document {
	public func findDoc(name: String) -> Document? { first(where: { $0.docType == name} ) }
}

extension Array where Element == ItemsRequest {
	public func findDoc(name: String) -> ItemsRequest? { first(where: { $0.docType == name} ) }
}

extension Array where Element == NameValue {
	public func findNameValue(name: String) -> NameValue? { first(where: { $0.name == name} ) }
}
