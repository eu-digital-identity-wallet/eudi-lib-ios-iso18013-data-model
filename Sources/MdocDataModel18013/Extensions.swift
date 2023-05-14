//
//  File.swift
//  
//
//  Created by ffeli on 14/05/2023.
//

import Foundation

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
}
