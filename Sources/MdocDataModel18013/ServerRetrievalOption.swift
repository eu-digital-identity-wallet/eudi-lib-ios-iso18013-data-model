//
//  ServerRetrievalOption.swift
//  Created by ffeli on 16/05/2023.
//

import Foundation
import SwiftCBOR

struct ServerRetrievalOption {
    static var version: UInt64 { 1 }
    public var url: String
    public var token: String
}

extension ServerRetrievalOption: CBOREncodable {
    func toCBOR(options: CBOROptions) -> CBOR {
        .array([.unsignedInt(Self.version), .utf8String(url), .utf8String(token) ])
    }
}

extension ServerRetrievalOption: CBORDecodable {
    init?(cbor: CBOR) {
        guard case let .array(arr) = cbor, arr.count > 2 else { return nil }
        guard case let .unsignedInt(v) = arr[0], v == Self.version else { return nil }
        guard case let .utf8String(u) = arr[1], case let .utf8String(t) = arr[2] else { return nil }
        url = u; token = t
    }
}
