import Foundation
import Testing
import SwiftCBOR
import OrderedCollections
@testable import MdocDataModel18013

struct SecurityFinding5Tests {
    @Test func rejectsTruncatedRetrievalMethods() {
        for type: UInt64 in [1, 2] {
            #expect(throws: MdocValidationError.self) {
                try DeviceRetrievalMethod(cbor: .array([.unsignedInt(type), .unsignedInt(1)]))
            }
        }
    }
    @Test func validatesPSMRange() throws {
        for peripheral in [true, false] {
            for psm: UInt64 in [0, 65535, 65536, UInt64.max] {
                let options: CBOR = .map([0: .boolean(peripheral), 1: .boolean(!peripheral),
                    .unsignedInt(peripheral ? 10 : 11): .byteString([UInt8](repeating: 0, count: 16)),
                    21: .unsignedInt(psm)])
                let method: CBOR = .array([2, 1, options])
                if psm <= 65535 { _ = try DeviceRetrievalMethod(cbor: method) }
                else { #expect(throws: MdocValidationError.self) { try DeviceRetrievalMethod(cbor: method) } }
            }
        }
        #expect(throws: MdocValidationError.self) {
            try DeviceRetrievalMethod(cbor: .array([2, 1, .map([21: .unsignedInt(65536)])]))
        }
    }
    @Test func validatesUUIDLength() throws {
        for length in [0, 1, 15, 16, 17, 32] {
            let bytes = [UInt8](repeating: 0, count: length)
            #expect((UUID(uuidBytes: bytes) != nil) == (length == 16))
            for peripheral in [true, false] {
                let options: CBOR = .map([0: .boolean(peripheral), 1: .boolean(!peripheral),
                    .unsignedInt(peripheral ? 10 : 11): .byteString(bytes)])
                let method: CBOR = .array([2, 1, options])
                if length == 16 { _ = try DeviceRetrievalMethod(cbor: method) }
                else { #expect(throws: MdocValidationError.self) { try DeviceRetrievalMethod(cbor: method) } }
            }
        }
    }
}
