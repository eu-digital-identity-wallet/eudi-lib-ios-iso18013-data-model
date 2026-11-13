import Foundation
import Testing
import SwiftCBOR
import OrderedCollections
@testable import MdocDataModel18013

struct SecurityFinding6Tests {
    @Test func integerBounds() throws {
        for value in [UInt64(Int64.max) + 1, UInt64.max] {
            #expect(throws: MdocValidationError.self) { try ZkParam(cbor: .unsignedInt(value)) }
            #expect(throws: MdocValidationError.self) { try ZkParam(cbor: .negativeInt(value)) }
            for code: CBOR in [.unsignedInt(value), .negativeInt(value)] {
                let useCase: CBOR = .map(["mandatory": true, "documentSets": [[0]], "purposeHints": ["controller": code]])
                #expect(throws: MdocValidationError.self) { try UseCase(cbor: useCase) }
            }
        }
        for value in [Int64.min, -1, 0, Int64.max] {
            let param = ZkParam.intParam(value)
            #expect(try ZkParam(cbor: param.toCBOR(options: CBOROptions())) == param)
        }
        let useCase = UseCase(mandatory: true, documentSets: [[0]], purposeHints: ["controller": Int.min])
        #expect(try UseCase(cbor: useCase.toCBOR(options: CBOROptions())).purposeHints?["controller"] == Int.min)
    }
    @Test func psmBounds() throws {
        for value: UInt64 in [65535, 65536, UInt64.max] {
            let cbor: CBOR = .array([2, 1, [0: true, 10: .byteString(Array(repeating: 0, count: 16)), 21: .unsignedInt(value)]])
            if value == 65535 { _ = try DeviceRetrievalMethod(cbor: cbor) }
            else { #expect(throws: MdocValidationError.self) { try DeviceRetrievalMethod(cbor: cbor) } }
        }
    }
    @Test func statusIndexBounds() {
        for value in [UInt64(Int.max), UInt64(Int.max) + 1, UInt64.max] {
            let mso: CBOR = ["status": ["status_list": ["idx": .unsignedInt(value), "uri": "https://example.test/status"]]]
            let data = CBOR.tagged(.encodedCBORDataItem, .byteString(mso.encode())).encode()
            #expect((StatusList(data: data) != nil) == (value == UInt64(Int.max)))
        }
    }
}
