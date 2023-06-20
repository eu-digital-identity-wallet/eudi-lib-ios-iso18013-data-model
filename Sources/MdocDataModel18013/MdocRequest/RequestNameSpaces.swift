import Foundation
import SwiftCBOR

/// contains the requested data elements and the namespace they belong to.
struct RequestNameSpaces {
    let nameSpaces: [NameSpace: RequestDataElements]
    subscript(ns: String)-> RequestDataElements? { nameSpaces[ns] }
} 

 
extension RequestNameSpaces: CBORDecodable {
	init?(cbor: CBOR) {
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
	func toCBOR(options: CBOROptions) -> CBOR {
		let m = nameSpaces.map { (ns: NameSpace, rde: RequestDataElements) -> (CBOR, CBOR) in
			(.utf8String(ns), rde.toCBOR(options: options))
		}
		return .map(Dictionary(m, uniquingKeysWith: { (d, _) in d }))
	}
}
