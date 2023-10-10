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

//
//  ServerRetrievalOptions.swift
//  Created on 16/05/2023.

import Foundation
import SwiftCBOR

/// Optional information on the server retrieval methods supported by the mdoc
public struct ServerRetrievalOptions: Equatable  {
	public var webAPI: ServerRetrievalOption?
	public var oIDC: ServerRetrievalOption?
	public var isEmpty:Bool { webAPI == nil && oIDC == nil }
    
    enum Keys : String {
        case webApi
        case oidc
    }
}

extension ServerRetrievalOptions: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        var cborMap = [CBOR: CBOR]()
        if let webAPI { cborMap[.utf8String(Keys.webApi.rawValue)] = webAPI.toCBOR(options: options) }
        if let oIDC { cborMap[.utf8String(Keys.oidc.rawValue)] = oIDC.toCBOR(options: options) }
        return .map(cborMap)
    }
}

extension ServerRetrievalOptions: CBORDecodable {
	public init?(cbor: CBOR) {
        guard case let .map(map) = cbor else { return nil }
        if let cborW = map[.utf8String(Keys.webApi.rawValue)] { webAPI = ServerRetrievalOption(cbor: cborW) }
        if let cborO = map[.utf8String(Keys.oidc.rawValue)] { oIDC = ServerRetrievalOption(cbor: cborO) }
        if isEmpty { return nil }
    }
}
