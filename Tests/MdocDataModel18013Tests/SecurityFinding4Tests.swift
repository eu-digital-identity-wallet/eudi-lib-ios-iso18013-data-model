import Foundation
import Testing
import SwiftCBOR
import OrderedCollections
@testable import MdocDataModel18013

struct SecurityFinding4Tests {
    @Test func rejectsWrongCOSEArity() {
        for count in [0, 1, 2, 3, 5] {
            #expect(Cose(type: .sign1, cbor: .array(Array(repeating: .null, count: count))) == nil)
        }
        let valid: CBOR = .array([.byteString([0xa1, 0x01, 0x26]), .map([:]), .null, .byteString([1])])
        #expect(Cose(type: .sign1, cbor: valid) != nil)
        #expect(Cose(type: .mac0, cbor: .array([])) == nil)
    }
}
