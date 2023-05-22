import CryptoKit
import Foundation
import SwiftCBOR

public protocol CBORDecodable {
    init?(data: [UInt8])
    init?(cbor: CBOR)
}

/// crv: EC identifier - Taken from the "COSE Elliptic Curves" registry
public enum ECCurveType: UInt64 {
    case p256 = 1
    case p384 = 2
    case p521 = 3
}

/// COSE_Key as defined in RFC 8152
struct CoseKey: Equatable {
    /// EC identifier
    let crv: ECCurveType
    /// key type
    var kty: UInt64 = 2
    /// value of x-coordinate
    let x: [UInt8]
    /// value of y-coordinate
    let y: [UInt8]
}

/// COSE_Key + private key
struct CoseKeyPrivate  {
    let key: CoseKey
    let d: [UInt8]
    
    init(crv: ECCurveType) {
        var privateKeyx963Data: Data
        switch crv {
        case .p256:
            let key = P256.Signing.PrivateKey(compactRepresentable: false)
            privateKeyx963Data = key.x963Representation
        case .p384:
            let key = P384.Signing.PrivateKey(compactRepresentable: false)
            privateKeyx963Data = key.x963Representation
        case .p521:
            let key = P521.Signing.PrivateKey(compactRepresentable: false)
            privateKeyx963Data = key.x963Representation
        }
        let xyk = privateKeyx963Data.advanced(by: 1) //Data(privateKeyx963Data[1...])
        let klen = xyk.count / 3
        let xdata: Data = Data(xyk[0..<klen])
        let ydata: Data = Data(xyk[klen..<2 * klen])
        let ddata: Data = Data(xyk[2 * klen..<3 * klen])
        key = CoseKey(crv: crv, x: xdata.bytes, y: ydata.bytes)
        d = ddata.bytes
    }
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

/*
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
 */
