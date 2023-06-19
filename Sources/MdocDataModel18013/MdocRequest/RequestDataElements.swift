import Foundation
import SwiftCBOR

typealias IntentToRetain = Bool

struct RequestDataElements {
    let dataElements: [DataElementIdentifier: IntentToRetain]
    var elementIdentifiers: [DataElementIdentifier] { Array(dataElements.keys) }
}

extension RequestDataElements: CBORDecodable {
	init?(cbor: CBOR) {
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
	func toCBOR(options: CBOROptions) -> CBOR {
		let m = dataElements.map { (dei: DataElementIdentifier, ir: IntentToRetain) -> (CBOR, CBOR) in
			(.utf8String(dei), .boolean(ir))
		}
		return .map(Dictionary(m, uniquingKeysWith: { (d, _) in d }))
	}
}
