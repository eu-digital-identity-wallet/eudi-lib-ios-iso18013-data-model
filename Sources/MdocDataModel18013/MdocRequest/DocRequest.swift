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

public struct DocRequest {
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
    public init?(cbor: CBOR) {
        guard case let .map(m) = cbor else { return nil }
        // item-request-bytes: tagged(24, items request)
        guard case let .tagged(_, cirb) = m[Keys.itemsRequest], case let .byteString(bs) = cirb, let ir = ItemsRequest(data: bs)  else { return nil }
        itemsRequestRawData = bs; itemsRequest = ir
        if let ra = m[Keys.readerAuth] { readerAuthRawCBOR = ra; readerAuth = ReaderAuth(cbor: ra) } else { readerAuthRawCBOR = nil; readerAuth = nil }
    }
}

extension DocRequest: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        var m = [CBOR: CBOR]()
		if let itemsRequestRawData { m[.utf8String(Keys.itemsRequest.rawValue)] = itemsRequestRawData.taggedEncoded }
        else { m[.utf8String(Keys.itemsRequest.rawValue)] = itemsRequest.toCBOR(options: options).taggedEncoded }
        if let readerAuth { m[.utf8String(Keys.readerAuth.rawValue)] = readerAuth.toCBOR(options: options) }
        return .map(m)
    }
}

extension DocRequest {
    public var readerCertificate: Data? {
        guard let ra = readerAuth else { return nil }
        guard let cert = ra.iaca.last else { return nil }
        return Data(cert)
    }
}
