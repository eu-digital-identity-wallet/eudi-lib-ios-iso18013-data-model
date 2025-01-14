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
import Logging
import OrderedCollections

/// Contains a returned cocument. The document type of the returned document is indicated by the docType element.
public struct Document: Sendable {

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
		var cbor = OrderedDictionary<CBOR, CBOR>()
		cbor[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
		cbor[.utf8String(Keys.issuerSigned.rawValue)] = issuerSigned.toCBOR(options: options)
		if let dsign = deviceSigned { cbor[.utf8String(Keys.deviceSigned.rawValue)] = dsign.toCBOR(options: options) }
		if let errors { cbor[.utf8String(Keys.errors.rawValue)] = errors.toCBOR(options: options) }
		return .map(cbor)
	}
}

extension Array where Element == Document {
	public func findDoc(name: String) -> (Document, Int)? {
		guard let index = firstIndex(where: { $0.docType == name} ) else { return nil }
		return (self[index], index)
	}
}

extension Array where Element == IssuerSigned {
	public func findDoc(name: String) -> (IssuerSigned, Int)? {
		guard let index = firstIndex(where: { $0.issuerAuth.mso.docType == name} ) else { return nil }
		return (self[index], index)
	}
}

extension Array where Element == DocRequest {
	public func findDoc(name: String) -> DocRequest? { first(where: { $0.itemsRequest.docType == name} ) }
}

extension Array where Element == DocClaim {
	public func findNameValue(name: String) -> DocClaim? { first(where: { $0.name == name} ) }
}
