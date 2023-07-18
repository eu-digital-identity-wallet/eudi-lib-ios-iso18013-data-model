//
//  IssuerSigned.swift

import Foundation
import SwiftCBOR

/// Contains the mobile security object for issuer data authentication and the data elements protected by issuer data authentication.
public struct IssuerSigned {
	public let issuerNameSpaces: IssuerNameSpaces?
	public let issuerAuth: IssuerAuth? //todo: make mandatory
	
	enum Keys: String {
	   case nameSpaces
	   case issuerAuth
	 }
	
	public init(issuerNameSpaces: IssuerNameSpaces? = nil, issuerAuth: IssuerAuth? = nil) {
		self.issuerNameSpaces = issuerNameSpaces
		self.issuerAuth = issuerAuth
	}
}

extension IssuerSigned: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		if let cn = m[Keys.nameSpaces] { issuerNameSpaces = IssuerNameSpaces(cbor: cn) } else { issuerNameSpaces = nil }
		//guard let cia = m[Keys.issuerAuth], let ia = IssuerAuth(cbor: cia) else { return nil }; issuerAuth = ia
		if let cia = m[Keys.issuerAuth], let ia = IssuerAuth(cbor: cia) { issuerAuth = ia } else { issuerAuth = nil }
	}
}

extension IssuerSigned: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = [CBOR: CBOR]()
		if let ns = issuerNameSpaces { cbor[.utf8String(Keys.nameSpaces.rawValue)] = ns.toCBOR(options: options) }
		if let ia = issuerAuth { cbor[.utf8String(Keys.issuerAuth.rawValue)] = ia.toCBOR(options: options) }
		return .map(cbor)
	}
}
