//
//  DeviceResponse.swift

import Foundation
import SwiftCBOR

/// Device retrieval mdoc response. It is CBOR encoded
///
/// In mdoc reader initialize from CBOR data received from holder (data exchange)
/// In mdoc holder initialize from CBOR data received from server (registration)
///
/// ```swift
/// let dr = DeviceResponse(data: bytes)
/// ```
public struct DeviceResponse {
	let version: String
	/// An array of all returned documents
	let documents: [Document]?
	/// An array of all returned document errors
	let documentErrors: [DocumentError]?
	let status: UInt64
	
	enum Keys: String {
		case version
		case documents
		case documentErrors
		case status
	}
}

extension DeviceResponse: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case .map(let cd) = cbor else { return nil }
		guard case .utf8String(let v) = cd[Keys.version] else { return nil }
		version = v
		if case let .array(ar) = cd[Keys.documents] {
			let ds = ar.compactMap { Document(cbor:$0) }
			if ds.count > 0 { documents = ds } else { documents = nil }
		} else { documents = nil }
		if case let .array(are) = cd[Keys.documentErrors] {
			let de = are.compactMap { DocumentError(cbor:$0) }
			if de.count > 0 { documentErrors = de } else { documentErrors = nil }
		}  else { documentErrors = nil }
		guard case .unsignedInt(let st) = cd[Keys.status] else { return nil }
		status = st
	}
}


