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

public struct ItemsRequest {
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
    public init?(cbor: CBOR) {
        guard case let .map(m) = cbor else { return nil }
        guard case let .utf8String(dt) = m[Keys.docType] else { return nil }
        docType = dt
        guard let cns = m[Keys.nameSpaces], let ns = RequestNameSpaces(cbor: cns)  else { return nil }
        requestNameSpaces = ns
        requestInfo = m[Keys.requestInfo]
    }
}

extension ItemsRequest: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = [CBOR: CBOR]()
        m[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
        m[.utf8String(Keys.nameSpaces.rawValue)] = requestNameSpaces.toCBOR(options: options)
        if let requestInfo { m[.utf8String(Keys.requestInfo.rawValue)] = requestInfo }
		return .map(m)
	}
}
