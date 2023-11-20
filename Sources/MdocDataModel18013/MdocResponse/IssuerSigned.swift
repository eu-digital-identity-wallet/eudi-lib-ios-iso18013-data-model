 /*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */

import Foundation
import SwiftCBOR

/// Contains the mobile security object for issuer data authentication and the data elements protected by issuer data authentication.
public struct IssuerSigned {
	public let issuerNameSpaces: IssuerNameSpaces?
	public let issuerAuth: IssuerAuth
	
	enum Keys: String {
	   case nameSpaces
	   case issuerAuth
	 }
	
	public init(issuerNameSpaces: IssuerNameSpaces?, issuerAuth: IssuerAuth) {
		self.issuerNameSpaces = issuerNameSpaces
		self.issuerAuth = issuerAuth
	}
}

extension IssuerSigned: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		if let cn = m[Keys.nameSpaces] { issuerNameSpaces = IssuerNameSpaces(cbor: cn) } else { issuerNameSpaces = nil }
		guard let cia = m[Keys.issuerAuth], let ia = IssuerAuth(cbor: cia) else { return nil }; issuerAuth = ia
	}
}

extension IssuerSigned: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = [CBOR: CBOR]()
		if let ns = issuerNameSpaces { cbor[.utf8String(Keys.nameSpaces.rawValue)] = ns.toCBOR(options: options) }
		cbor[.utf8String(Keys.issuerAuth.rawValue)] = issuerAuth.toCBOR(options: options)
		return .map(cbor)
	}
}
