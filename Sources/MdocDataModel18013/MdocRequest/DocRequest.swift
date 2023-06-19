import Foundation
import SwiftCBOR

struct DocRequest {
    let itemsRequest: ItemsRequest
    let readerAuth: ReaderAuth?

    enum Keys: String {
        case itemsRequest
        case readerAuth
    }
}

extension DocRequest: CBORDecodable {
    init?(cbor: CBOR) {
        guard case let .map(m) = cbor else { return nil }
        // item-request-bytes: tagged(24, items request)
        guard case let .tagged(_, cirb) = m[Keys.itemsRequest], case let .byteString(bs) = cirb, let ir = ItemsRequest(data: bs)  else { return nil }
        itemsRequest = ir
        if let ra = m[Keys.readerAuth] { readerAuth = ReaderAuth(cbor: ra) } else { readerAuth = nil }
    }
}

extension DocRequest: CBOREncodable {
	func toCBOR(options: CBOROptions) -> CBOR {
        var m = [CBOR: CBOR]()
        m[.utf8String(Keys.itemsRequest.rawValue)] = itemsRequest.toCBOR(options: options)
        if let readerAuth { m[.utf8String(Keys.readerAuth.rawValue)] = readerAuth.toCBOR(options: options) }
        return .map(m)
    }
}