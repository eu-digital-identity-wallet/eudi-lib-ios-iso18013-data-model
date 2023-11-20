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

/// Device retrieval mdoc response. It is CBOR encoded
///
/// In mdoc reader initialize from CBOR data received from holder (data exchange)
/// In mdoc holder initialize from CBOR data received from server (registration)
///
/// ```swift
/// let dr = DeviceResponse(data: bytes)
/// ```
public struct DeviceResponse {
	public let version: String
	static let defaultVersion = "1.0"
	/// An array of all returned documents
	public let documents: [Document]?
	/// An array of all returned document errors
	public let documentErrors: [DocumentError]?
	public let status: UInt64
	
	enum Keys: String {
		case version
		case documents
		case documentErrors
		case status
	}

	public init(version: String? = nil, documents: [Document]? = nil, documentErrors: [DocumentError]? = nil, status: UInt64) {
		self.version = version ?? Self.defaultVersion
		self.documents = documents
		self.documentErrors = documentErrors
		self.status = status
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

extension DeviceResponse: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = [CBOR: CBOR]()
		cbor[.utf8String(Keys.version.rawValue)] = .utf8String(version)
		if let ds = documents { cbor[.utf8String(Keys.documents.rawValue)] = ds.toCBOR(options: options) }
		if let de = documentErrors { cbor[.utf8String(Keys.documentErrors.rawValue)] = .array(de.map {$0.toCBOR(options: options)}) }
		cbor[.utf8String(Keys.status.rawValue)] = .unsignedInt(status)
		return .map(cbor)
	}
}

