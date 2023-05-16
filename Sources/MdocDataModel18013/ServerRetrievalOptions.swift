//
//  ServerRetrievalOptions.swift
//  Created by ffeli on 16/05/2023.

import Foundation
import SwiftCBOR

struct ServerRetrievalOptions  {
    var webAPI: ServerRetrievalOption?
    var oIDC: ServerRetrievalOption?
    var isEmpty:Bool { webAPI == nil && oIDC == nil }
    
    enum Keys : String {
        case webApi
        case oidc
    }
}

extension ServerRetrievalOptions: CBOREncodable {
    func toCBOR(options: CBOROptions) -> CBOR {
        var cborMap = [CBOR: CBOR]()
        if let webAPI { cborMap[.utf8String(Keys.webApi.rawValue)] = webAPI.toCBOR(options: options) }
        if let oIDC { cborMap[.utf8String(Keys.oidc.rawValue)] = oIDC.toCBOR(options: options) }
        return .map(cborMap)
    }
}

extension ServerRetrievalOptions: CBORDecodable {
    init?(cbor: CBOR) {
        guard case let .map(map) = cbor else { return nil }
        if let cborW = map[.utf8String(Keys.webApi.rawValue)] { webAPI = ServerRetrievalOption(cbor: cborW) }
        if let cborO = map[.utf8String(Keys.oidc.rawValue)] { oIDC = ServerRetrievalOption(cbor: cborO) }
    }
}
