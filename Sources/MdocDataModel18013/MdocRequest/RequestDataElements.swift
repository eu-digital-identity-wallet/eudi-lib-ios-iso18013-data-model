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

public typealias IntentToRetain = Bool

/// Requested data elements identified by their data element identifier.
public struct RequestDataElements: Sendable {
	/// IntentToRetain indicates whether the mdoc verifier intends to retain the received data element
    public let dataElements: [DataElementIdentifier: IntentToRetain]
    public var elementIdentifiers: [DataElementIdentifier] { Array(dataElements.keys) }
}

extension RequestDataElements: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
  		guard case let .map(e) = cbor else { throw .requestDataElementsInvalidCbor }
		let dePairs = try e.map { (k: CBOR, v: CBOR)  throws(MdocValidationError) -> (DataElementIdentifier, Bool) in
			guard case .utf8String(let dei) = k else { throw .requestDataElementsInvalidCbor }
			guard case .boolean(let ir) = v else { throw .requestDataElementsInvalidCbor }
			return (dei, ir)
		}
        let de = Dictionary(dePairs, uniquingKeysWith: { (first, _) in first })
		if de.count == 0 { throw .requestDataElementsInvalidCbor }
		dataElements = de
    }
}

extension RequestDataElements: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		let m = dataElements.map { (dei: DataElementIdentifier, ir: IntentToRetain) -> (CBOR, CBOR) in
			(.utf8String(dei), .boolean(ir))
		}
		return .map(OrderedDictionary(m, uniquingKeysWith: { (d, _) in d }))
	}
}
