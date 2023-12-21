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
		return .map(OrderedDictionary(m, uniquingKeysWith: { (d, _) in d }))
	}
}
