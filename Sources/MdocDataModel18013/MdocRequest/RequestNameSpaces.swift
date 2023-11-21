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

/// contains the requested data elements and the namespace they belong to.
public struct RequestNameSpaces {
    public let nameSpaces: [NameSpace: RequestDataElements]
    public subscript(ns: String)-> RequestDataElements? { nameSpaces[ns] }
} 

 
extension RequestNameSpaces: CBORDecodable {
	public init?(cbor: CBOR) {
  		guard case let .map(e) = cbor else { return nil }
		let dePairs = e.compactMap { (k: CBOR, v: CBOR) -> (NameSpace, RequestDataElements)?  in
			guard case .utf8String(let ns) = k else { return nil }
			guard let rde = RequestDataElements(cbor: v) else { return nil }
			return (ns, rde)
		}      
        let de = Dictionary(dePairs, uniquingKeysWith: { (first, _) in first })
		if de.count == 0 { return nil }
		nameSpaces = de
    }
}

extension RequestNameSpaces: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		let m = nameSpaces.map { (ns: NameSpace, rde: RequestDataElements) -> (CBOR, CBOR) in
			(.utf8String(ns), rde.toCBOR(options: options))
		}
		return .map(Dictionary(m, uniquingKeysWith: { (d, _) in d }))
	}
}
