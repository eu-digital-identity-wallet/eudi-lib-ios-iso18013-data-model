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
		return .map(OrderedDictionary(m, uniquingKeysWith: { (d, _) in d }))
	}
}
