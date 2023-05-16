//COSE_Key as defined in RFC 8152;
//In accordance with RFC 8152, the CDDL grammar describing a COSE_Key as used in the device retrieval security mechanisms is:
//COSE_Key = {
//1 => int, ; kty: key type
//-1 => int, ; crv: EC identifier - Taken from the "COSE Elliptic Curves" registry
//-2 => bstr, ; x: value of x-coordinate
//? -3 => bstr / bool ; y: value or sign bit of y-coordinate; only applicable for EC2 key types
//}

import CryptoKit
import Foundation
import SwiftCBOR

protocol CBORDecodable {
    init?(data: [UInt8])
    init?(cbor: CBOR)
}

enum ECCurveType: UInt64 {
    case p256 = 1
    case p384 = 2
    case p521 = 3
}

struct CoseKey {
    let crv: ECCurveType
    var kty: UInt64 = 2
    let x: [UInt8]
    let y: [UInt8]
}

struct CoseKeyPrivate  {
    let key: CoseKey
    let d: [UInt8]
}

extension CoseKey: CBOREncodable {
    func toCBOR(options: CBOROptions) -> CBOR {
        let cbor: CBOR = [
            -1: .unsignedInt(crv.rawValue), 1: .unsignedInt(kty),
             -2: .byteString(x), -3: .byteString(y),
        ]
        return cbor
    }
}

extension CoseKey: CBORDecodable {
    init?(cbor obj: CBOR) {
        guard let calg = obj[-1], case let CBOR.unsignedInt(ralg) = calg, let alg = ECCurveType(rawValue: ralg) else { return nil }
        crv = alg
        guard let ckty = obj[1], case let CBOR.unsignedInt(rkty) = ckty else { return nil }
        kty = rkty
        guard let cx = obj[-2], case let CBOR.byteString(rx) = cx else { return nil }
        x = rx
        guard let cy = obj[-3], case let CBOR.byteString(ry) = cy else { return nil }
        y = ry
    }
}

extension CoseKeyPrivate: CBOREncodable {
    func toCBOR(options: CBOROptions) -> CBOR {
        var cbor = key.toCBOR(options: options)
        cbor[-4] = .byteString(d)
        return cbor
    }
}

extension CoseKeyPrivate: CBORDecodable {
    init?(cbor obj: SwiftCBOR.CBOR) {
        guard let key = CoseKey(cbor: obj)  else { return nil }
        self.key = key
        guard let cd = obj[-4], case let CBOR.byteString(rd) = cd else { return nil }
        d = rd
    }
    
    init?(data: [UInt8]) {
        guard let obj = try? CBOR.decode(data) else { return nil }
        self.init(cbor: obj)
    }
}
