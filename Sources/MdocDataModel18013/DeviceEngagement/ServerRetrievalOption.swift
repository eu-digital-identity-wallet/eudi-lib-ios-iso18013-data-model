//
//  ServerRetrievalOption.swift
//  Created by ffeli on 16/05/2023.
//

import Foundation
import SwiftCBOR

/// Server retrieval information
struct ServerRetrievalOption: Equatable {
    static var versionImpl: UInt64 { 1 }
    var version: UInt64 = Self.versionImpl
    var url: String
    var token: String
}

extension ServerRetrievalOption: CBOREncodable {
    func toCBOR(options: CBOROptions) -> CBOR {
        .array([.unsignedInt(Self.versionImpl), .utf8String(url), .utf8String(token) ])
    }
}

extension ServerRetrievalOption: CBORDecodable {
    init?(cbor: CBOR) {
        guard case let .array(arr) = cbor, arr.count > 2 else { return nil }
        guard case let .unsignedInt(v) = arr[0], v == Self.versionImpl else { return nil }
        guard case let .utf8String(u) = arr[1], case let .utf8String(t) = arr[2] else { return nil }
        version = v; url = u; token = t
    }
}
