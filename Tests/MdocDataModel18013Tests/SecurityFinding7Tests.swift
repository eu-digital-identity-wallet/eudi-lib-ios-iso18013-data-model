import Foundation
import Testing
import SwiftCBOR
import OrderedCollections
@testable import MdocDataModel18013

struct SecurityFinding7Tests {
    @Test func rejectsResourceExhaustionBeforeMaterialization() throws {
        for bytes: [UInt8] in [
            Array(repeating: 0x81, count: 66) + [0],
            Array(repeating: 0xc0, count: 66) + [0],
            [0x9b, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff],
            [0xbb, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff],
            [0x9f, 0x81]
        ] {
            #expect(throws: MdocValidationError.self) { try MdocCBOR.decode(bytes) }
        }
        #expect(try MdocCBOR.decode([0x82, 0, 1]) == .array([0, 1]))
        #expect(try MdocCBOR.decode([0x9f, 0, 1, 0xff]) == .array([0, 1]))
        #expect(try MdocCBOR.decode(Array(repeating: 0x81, count: 64) + [0]) != nil)
    }
    @Test func embeddedBytesUseSameBound() {
        let bytes = Array(repeating: UInt8(0x81), count: 66) + [0]
        #expect(CBOR.byteString(bytes).decodeBytestring() == nil)
        #expect(throws: MdocValidationError.self) { try IssuerSignedItem(data: bytes) }
        #expect(throws: MdocValidationError.self) { try DeviceEngagement(data: bytes) }
    }
}
