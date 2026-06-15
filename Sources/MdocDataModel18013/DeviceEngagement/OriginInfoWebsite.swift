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

public struct OriginInfoWebsite: Sendable {
	public static let ENGAGEMENT_VERSION_1_1 = "1.1"
	// * The constant used to specify how the current engagement structure is delivered.
	static let CAT_DELIVERY: UInt64 = 0
	// * The constant used to specify how the other party engagement structure has been received.
	static let CAT_RECEIVE: UInt64 = 1
	static let TYPE: UInt64 = 100
	private let mCat: UInt64
	private let mBaseUrl: String
	public init(baseUrl: String, cat: UInt64 = 1) {
		mCat = cat
		mBaseUrl = baseUrl
	}
}

extension OriginInfoWebsite: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		let detailsMap: CBOR = .map(["baseUrl": .utf8String(mBaseUrl)])
		let originInfoMap: CBOR = .map([
			"cat": .unsignedInt(mCat),
			"type": .unsignedInt(Self.TYPE),
			"Details": detailsMap,
		])
		return originInfoMap
	}
}

extension OriginInfoWebsite: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(originInfoMap) = cbor else { throw .invalidCbor("origin info website") }
		guard case let .unsignedInt(category) = originInfoMap["cat"] else { throw .missingField("OriginInfoWebsite", "cat") }
		guard case let .map(detailsMap) = originInfoMap["Details"], case let .utf8String(baseUrl) = detailsMap["baseUrl"] else {
			throw .missingField("OriginInfoWebsite", "baseUrl")
		}
		self.init(baseUrl: baseUrl, cat: category)
	}
}
