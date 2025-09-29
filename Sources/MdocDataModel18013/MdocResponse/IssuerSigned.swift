/*
Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation
import SwiftCBOR
import OrderedCollections

/// Contains the mobile security object for issuer data authentication and the data elements protected by issuer data authentication.
public struct IssuerSigned: Sendable {
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
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(m) = cbor else { throw .invalidCbor("issuer signed") }
		if let cn = m[Keys.nameSpaces] { issuerNameSpaces = try IssuerNameSpaces(cbor: cn) } else { issuerNameSpaces = nil }
		guard let cia = m[Keys.issuerAuth] else { throw .missingField("IssuerSigned", Keys.issuerAuth.rawValue) }
        issuerAuth = try IssuerAuth(cbor: cia)
	}
}

extension IssuerSigned: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = OrderedDictionary<CBOR, CBOR>()
		if let ns = issuerNameSpaces { cbor[.utf8String(Keys.nameSpaces.rawValue)] = ns.toCBOR(options: options) }
		cbor[.utf8String(Keys.issuerAuth.rawValue)] = issuerAuth.toCBOR(options: options)
		return .map(cbor)
	}
}

extension IssuerSigned {
    public var validFrom: Date? {
        issuerAuth.mso.validityInfo.validFrom.convertToLocalDate()
    }

    public var validUntil: Date? {
        issuerAuth.mso.validityInfo.validUntil.convertToLocalDate()
    }
}
