//
//  Extensions.swift


import Foundation
import SwiftCBOR

extension String {
    public var hex_decimal: Int {
        return Int(self, radix: 16)!
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    public var byteArray: [UInt8] {
        var res = [UInt8]()
        for offset in stride(from: 0, to: count, by: 2) {
            let byte = self[offset..<offset+2].hex_decimal
            res.append(UInt8(byte))
        }
        return res
    }
    var fullDateEncoded: CBOR {
        CBOR.tagged(CBOR.Tag(rawValue: 1004), .utf8String(self))
    }
}

extension Data {
  public var bytes: Array<UInt8> {
    Array(self)
  }
}

 
extension Array where Element == UInt8 {
    var hex: String {
           var str = ""
           for byte in self {
               str = str.appendingFormat("%02X", UInt(byte))
           }
           return str
    }
}

extension CBOREncodable {
    func encode(options: SwiftCBOR.CBOROptions) -> [UInt8] {
        toCBOR(options: CBOROptions()).encode()
    }
    var taggedEncoded: CBOR {
        CBOR.tagged(CBOR.Tag(rawValue: 24), .byteString(CBOR.encode(self)))
    }
}

extension CBORDecodable {
    init?(data: [UInt8]) {
        guard let obj = try? CBOR.decode(data) else { return nil }
        self.init(cbor: obj)
    }
}

extension CBOR {
    func decodeTagged<T: CBORDecodable>(_ t: T.Type = T.self) -> T? {
        guard case let CBOR.tagged(tag, cborEncoded) = self, tag.rawValue == 24, case let .byteString(bytes) = cborEncoded else {  return nil }
        return .init(data: bytes)
    }
    
    func decodeFullDate() -> String? {
        guard case let CBOR.tagged(tag, cborEncoded) = self, tag.rawValue == 1004, case let .utf8String(s) = cborEncoded else { return nil }
        return s
    }
}
