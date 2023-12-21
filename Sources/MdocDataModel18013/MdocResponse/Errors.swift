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
public typealias ErrorItems = [DataElementIdentifier: ErrorCode]

/// Error codes for each namespace for items that are not returned
public struct Errors {
	
	public let errors: [NameSpace: ErrorItems]
	public subscript(ns: String) -> ErrorItems? { errors[ns] }
	
	public init(errors: [NameSpace : ErrorItems]) {
		self.errors = errors
	}
}

extension Errors: CBORDecodable {
	public init?(cbor: CBOR) {
        guard case let .map(e) = cbor else { return nil }
        if e.count == 0 { return nil }
        let pairs = e.compactMap { (key: CBOR, value: CBOR) -> (NameSpace, ErrorItems)? in
            guard case .utf8String(let ns) = key else { return nil }
            guard case .map(let m) = value else { return nil }
            let eiPairs = m.compactMap { (k: CBOR, v: CBOR) -> (DataElementIdentifier, ErrorCode)?  in
                guard case .utf8String(let dei) = k else { return nil }
                guard case .unsignedInt(let ec) = v else { return nil }
                return (dei,ec)
            }
            let ei = Dictionary(eiPairs, uniquingKeysWith: { (first, _) in first })
            if ei.count == 0 { return nil }
            return (ns, ei)
        }
        errors = Dictionary(pairs, uniquingKeysWith: { (first, _) in first })
    }
}

extension Errors: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        let map1 = errors.map { (ns: NameSpace, ei: ErrorItems) -> (CBOR, CBOR) in
            let kns = CBOR.utf8String(ns)
            let mei = ei.map { (dei: DataElementIdentifier, ec: ErrorCode) -> (CBOR, CBOR) in
                (.utf8String(dei), .unsignedInt(ec))
            }
            return (kns, .map(OrderedDictionary(mei, uniquingKeysWith: { (d, _) in d })))
        }
        let cborMap = OrderedDictionary(map1, uniquingKeysWith: { (ns, _) in ns })
        return .map(cborMap)
    }
}

