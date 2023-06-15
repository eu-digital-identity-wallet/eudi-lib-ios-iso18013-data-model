//
//  IssuerSignedItem.swift

import Foundation
import SwiftCBOR

/// Data item signed by issuer
struct IssuerSignedItem {
    /// Digest ID for issuer data authentication
    let digestID: UInt64
    /// Random value for issuer data authentication
    let random: [UInt8]
    /// Data element identifier
    let elementIdentifier: DataElementIdentifier
    /// Data element value
    let elementValue: DataElementValue
    /// Raw CBOR data
    var rawData: [UInt8]?
    
    enum Keys: String {
       case digestID
       case random
       case elementIdentifier
       case elementValue
     }
}

extension IssuerSignedItem: CustomStringConvertible {
    var description: String {
        switch elementValue {
        case .utf8String(let str): return str
        case .byteString(_): return "ByteString"
        case .tagged(_, .utf8String(let str)): return str
        case .unsignedInt(let i): return String(i)
        case .boolean(let b): return String(b)
        default: return String(reflecting: elementValue)
        }
    }
}

extension IssuerSignedItem: CBORDecodable {
    init?(data: [UInt8]) {
        guard let obj = try? CBOR.decode(data) else { return nil }
        guard case let CBOR.tagged(tag, cborEncoded) = obj, tag.rawValue == 24, case let .byteString(bytes) = cborEncoded else { return nil }
        guard let cbor = try? CBOR.decode(bytes) else { return nil }
        self.init(cbor: cbor)
        rawData = data
    }

    init?(cbor: CBOR) {
		guard case .map(let cd) = cbor else { return nil }
        guard case .unsignedInt(let did) = cd[Keys.digestID] else { return nil }
        digestID = did
        guard case .byteString(let r) = cd[Keys.random] else { return nil }
        random = r
        guard case .utf8String(let ei) = cd[Keys.elementIdentifier] else { return nil }
        elementIdentifier = ei
        guard let ev = cd[Keys.elementValue] else { return nil }
        elementValue = ev
    }
}

extension IssuerSignedItem: CBOREncodable {
    /// called IssuerSignedItemBytes
    func encode(options: CBOROptions) -> [UInt8] {
        if let rawData { return rawData }
        // it is not recommended to encode again, the digest may change
        return toCBOR(options: CBOROptions()).taggedEncoded.encode()
    }
    
    func toCBOR(options: CBOROptions) -> CBOR {
        var cbor = [CBOR: CBOR]()
        cbor[.utf8String(Keys.digestID.rawValue)] = .unsignedInt(digestID)
        cbor[.utf8String(Keys.random.rawValue)] = .byteString(random)
        cbor[.utf8String(Keys.elementIdentifier.rawValue)] = .utf8String(elementIdentifier)
        cbor[.utf8String(Keys.elementValue.rawValue)] = elementValue
        return .map(cbor)
    }
}
