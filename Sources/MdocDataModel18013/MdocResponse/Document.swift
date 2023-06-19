//
//  Document.swift

import Foundation
import SwiftCBOR

/// Contains a returned cocument. The document type of the returned document is indicated by the docType element.
struct Document {
	let docType: DocType
	let issuerSigned: IssuerSigned
	let deviceSigned: DeviceSigned
	/// error codes for data elements that are not returned
	let errors: Errors?
	
	enum Keys:String {
		case docType
		case issuerSigned
		case deviceSigned
		case errors
	}
}

extension Document: CBORDecodable {
	init?(cbor: CBOR) {
		guard case .map(let cd) = cbor else { return nil }
		guard case .utf8String(let dt) = cd[Keys.docType] else { return nil }
		docType = dt
		guard let cis = cd[Keys.issuerSigned], let `is` = IssuerSigned(cbor: cis) else { return nil }
		issuerSigned = `is`
		guard let cds = cd[Keys.deviceSigned], let ds = DeviceSigned(cbor: cds) else { return nil }
		deviceSigned = ds
		if let ce = cd[Keys.errors], let e = Errors(cbor: ce) { errors = e} else { errors = nil }
	}
}
