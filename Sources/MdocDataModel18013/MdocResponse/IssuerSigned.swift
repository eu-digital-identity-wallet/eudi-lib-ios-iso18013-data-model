//
//  IssuerSigned.swift

import Foundation
import SwiftCBOR

/// Contains the mobile security object for issuer data authentication and the data elements protected by issuer data authentication.
struct IssuerSigned {
	let nameSpaces: IssuerNameSpaces?
	let issuerAuth: IssuerAuth? //todo: make mandatory
	
	enum Keys: String {
	   case nameSpaces
	   case issuerAuth
	 }
}

extension IssuerSigned: CBORDecodable {
	init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		if let cn = m[Keys.nameSpaces] { nameSpaces = IssuerNameSpaces(cbor: cn) } else { nameSpaces = nil }
		//guard let cia = m[Keys.issuerAuth], let ia = IssuerAuth(cbor: cia) else { return nil }; issuerAuth = ia
		if let cia = m[Keys.issuerAuth], let ia = IssuerAuth(cbor: cia) { issuerAuth = ia } else { issuerAuth = nil }
	}
}
