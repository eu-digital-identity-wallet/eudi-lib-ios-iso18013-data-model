/*
Copyright (c) 2026 European Commission

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
public struct DocumentError: Sendable {

	public let docErrors: [DocType: ErrorCode]
	public subscript(dt: DocType) -> ErrorCode? { docErrors[dt] }

	public init(docErrors: [DocType : ErrorCode]) {
		self.docErrors = docErrors
	}
}

extension DocumentError: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(errorMap) = cbor else { throw MdocValidationError.invalidCbor("document error") }
		let docErrorPairs = try errorMap.map { (key: CBOR, value: CBOR) throws(MdocValidationError) -> (DocType, ErrorCode)  in
			guard case .utf8String(let docType) = key else { throw .invalidCbor("document error") }
			guard case .unsignedInt(let errorCode) = value else { throw .invalidCbor("document error") }
			return (docType, errorCode)
		}
		let docErrorsMap = Dictionary(docErrorPairs, uniquingKeysWith: { (first, _) in first })
		if docErrorsMap.count == 0 { throw .invalidCbor("document error") }
		docErrors = docErrorsMap
	}
}

extension DocumentError: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		let entries = docErrors.map { (docType: DocType, errorCode: ErrorCode) -> (CBOR, CBOR) in
			(.utf8String(docType), .unsignedInt(errorCode))
		}
		return .map(OrderedDictionary(entries, uniquingKeysWith: { (key, _) in key }))
	}
}
