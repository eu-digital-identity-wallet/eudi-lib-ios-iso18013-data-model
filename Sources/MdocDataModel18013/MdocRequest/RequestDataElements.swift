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

public typealias IntentToRetain = Bool

/// Requested data elements identified by their data element identifier.
public struct RequestDataElements {
	/// IntentToRetain indicates whether the mdoc verifier intends to retain the received data element
    public let dataElements: [DataElementIdentifier: IntentToRetain]
    public var elementIdentifiers: [DataElementIdentifier] { Array(dataElements.keys) }
}

extension RequestDataElements: CBORDecodable {
	public init?(cbor: CBOR) {
  		guard case let .map(e) = cbor else { return nil }
		let dePairs = e.compactMap { (k: CBOR, v: CBOR) -> (DataElementIdentifier, Bool)?  in
			guard case .utf8String(let dei) = k else { return nil }
			guard case .boolean(let ir) = v else { return nil }
			return (dei, ir)
		}      
        let de = Dictionary(dePairs, uniquingKeysWith: { (first, _) in first })
		if de.count == 0 { return nil }
		dataElements = de
    }
}

extension RequestDataElements: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		let m = dataElements.map { (dei: DataElementIdentifier, ir: IntentToRetain) -> (CBOR, CBOR) in
			(.utf8String(dei), .boolean(ir))
		}
		return .map(Dictionary(m, uniquingKeysWith: { (d, _) in d }))
	}
}
