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
