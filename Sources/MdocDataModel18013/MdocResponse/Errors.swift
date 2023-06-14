//
//  Errors.swift

import Foundation
import SwiftCBOR

typealias ErrorItems = [DataElementIdentifier: ErrorCode]
typealias DocumentError = [DocType: ErrorCode]

/// Error codes for each namespace
struct Errors {
    let errors: [NameSpace: ErrorItems]
    subscript(ns: String) -> ErrorItems? { errors[ns] }
}

extension Errors: CBORDecodable {
    init?(cbor: CBOR) {
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
    func toCBOR(options: CBOROptions) -> CBOR {
        let map1 = errors.map { (ns: NameSpace, ei: ErrorItems) -> (CBOR, CBOR) in
            let kns = CBOR.utf8String(ns)
            let mei = ei.map { (dei: DataElementIdentifier, ec: ErrorCode) -> (CBOR, CBOR) in
                (.utf8String(dei), .unsignedInt(ec))
            }
            return (kns, .map(Dictionary(mei, uniquingKeysWith: { (d, _) in d })))
        }
        let cborMap = Dictionary(map1, uniquingKeysWith: { (ns, _) in ns })
        return .map(cborMap)
    }
}

