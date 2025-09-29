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

public struct ItemsRequest: Sendable {
	/// Requested document type.
    public let docType: DocType
	/// Requested data elements for each NameSpace
    public let requestNameSpaces: RequestNameSpaces
	/// May be used by the mdoc reader to provide additional information
    let requestInfo: CBOR?

    enum Keys: String {
        case docType
        case nameSpaces
        case requestInfo
    }
}

extension ItemsRequest: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(m) = cbor else { throw .itemsRequestInvalidCbor }
        guard case let .utf8String(dt) = m[Keys.docType] else { throw .itemsRequestMissingField(Keys.docType.rawValue) }
        docType = dt
        guard let cns = m[Keys.nameSpaces]  else { throw .itemsRequestMissingField(Keys.nameSpaces.rawValue) }
        requestNameSpaces = try RequestNameSpaces(cbor: cns)
        requestInfo = m[Keys.requestInfo]
    }
}

extension ItemsRequest: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = OrderedDictionary<CBOR, CBOR>()
        m[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
        m[.utf8String(Keys.nameSpaces.rawValue)] = requestNameSpaces.toCBOR(options: options)
        if let requestInfo { m[.utf8String(Keys.requestInfo.rawValue)] = requestInfo }
		return .map(m)
	}
}
