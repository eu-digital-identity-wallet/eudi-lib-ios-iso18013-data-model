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

public struct DocRequest: Sendable {
    public let itemsRequest: ItemsRequest
    public let itemsRequestRawData: [UInt8]? // items-request raw data NOT tagged
	/// Used for mdoc reader authentication
    let readerAuth: ReaderAuth?
    public let readerAuthRawCBOR: CBOR?

    enum Keys: String {
        case itemsRequest
        case readerAuth
    }
}

extension DocRequest: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(m) = cbor else { throw .docRequestInvalidCbor }
        // item-request-bytes: tagged(24, items request)
        guard case let .tagged(t, cirb) = m[Keys.itemsRequest], t == .encodedCBORDataItem, case let .byteString(bs) = cirb else { throw .docRequestInvalidCbor }
        do { itemsRequest = try ItemsRequest(data: bs) } catch { throw .docRequestInvalidCbor }
        itemsRequestRawData = bs
        if let ra = m[Keys.readerAuth] { readerAuthRawCBOR = ra; readerAuth = try ReaderAuth(cbor: ra) } else { readerAuthRawCBOR = nil; readerAuth = nil }
    }
}

extension DocRequest: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        var m = OrderedDictionary<CBOR, CBOR>()
		if let itemsRequestRawData { m[.utf8String(Keys.itemsRequest.rawValue)] = itemsRequestRawData.taggedEncoded }
        else { m[.utf8String(Keys.itemsRequest.rawValue)] = itemsRequest.toCBOR(options: options).taggedEncoded }
        if let readerAuth { m[.utf8String(Keys.readerAuth.rawValue)] = readerAuth.toCBOR(options: options) }
        return .map(m)
    }
}

extension DocRequest {
    public var readerCertificates: [Data] {
        guard let ra = readerAuth else { return [] }
		return ra.x5chain.map { Data($0) }
    }
}
