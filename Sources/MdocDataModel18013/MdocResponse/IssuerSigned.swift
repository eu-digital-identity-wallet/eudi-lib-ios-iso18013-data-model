//
//  IssuerSigned.swift

import Foundation
import SwiftCBOR

struct IssuerSigned {
	let nameSpaces: IssuerNameSpaces?
	let issuerAuth: IssuerAuth
	
	enum Keys: String {
	   case nameSpaces
	   case issuerAuth
	 }
}

extension IssuerSigned: CBORDecodable {
	init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		if let cn = m[Keys.nameSpaces] { nameSpaces = IssuerNameSpaces(cbor: cn) } else { nameSpaces = nil }
		guard let cia = m[Keys.issuerAuth], let ia = IssuerAuth(cbor: cia) else { return nil }
		issuerAuth = ia
	}
}
