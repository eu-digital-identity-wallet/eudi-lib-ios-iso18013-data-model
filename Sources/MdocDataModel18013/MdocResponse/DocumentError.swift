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

/// Error codes for documents that are not returned
public struct DocumentError {
	
	public let docErrors: [DocType: ErrorCode]
	public subscript(dt: DocType) -> ErrorCode? { docErrors[dt] }

	public init(docErrors: [DocType : ErrorCode]) {
		self.docErrors = docErrors
	}
}

extension DocumentError: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(e) = cbor else { return nil }
		let dePairs = e.compactMap { (k: CBOR, v: CBOR) -> (DocType, ErrorCode)?  in
			guard case .utf8String(let dt) = k else { return nil }
			guard case .unsignedInt(let ec) = v else { return nil }
			return (dt,ec)
		}
		let de = Dictionary(dePairs, uniquingKeysWith: { (first, _) in first })
		if de.count == 0 { return nil }
		docErrors = de
	}
}

extension DocumentError: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		let m = docErrors.map { (dt: DocType, ec: ErrorCode) -> (CBOR, CBOR) in
			(.utf8String(dt), .unsignedInt(ec))
		}
		return .map(Dictionary(m, uniquingKeysWith: { (d, _) in d }))
	}
}
