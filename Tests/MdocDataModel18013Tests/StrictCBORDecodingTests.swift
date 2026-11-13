/*
Copyright (c) 2026 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import Foundation
import SwiftCBOR
import Testing
@testable import MdocDataModel18013

struct StrictCBORDecodingTests {
    // Duplicate integer keys, including an alternate encoding of the same key.
    @Test(arguments: [
        [UInt8](arrayLiteral: 0xA2, 0x01, 0x02, 0x01, 0x03),
        [0xBF, 0x01, 0x02, 0x01, 0x03, 0xFF],
        [0xA2, 0x01, 0x02, 0x18, 0x01, 0x03]
    ])
    func rejectsDuplicateKeys(bytes: [UInt8]) {
        #expect(throws: (any Error).self) { try CBOR.decodeMdoc(bytes) }
        #expect(throws: (any Error).self) { try CBOR.decodeMdoc([0x81] + bytes) }
    }

    @Test(arguments: [[UInt8](arrayLiteral: 0x00), [0xFF], [0x18], [0xFF, 0x00]])
    func rejectsTrailingBytes(suffix: [UInt8]) {
        #expect(throws: (any Error).self) { try CBOR.decodeMdoc([0xA0] + suffix) }
        #expect(throws: (any Error).self) {
            try DeviceResponse(data: DeviceResponse().encode(options: CBOROptions()) + suffix)
        }
    }

    @Test func acceptsValidMaps() throws {
        #expect(try CBOR.decodeMdoc([0xA1, 0x01, 0x02]) == .map([1: 2]))
        #expect(try CBOR.decodeMdoc([0xBF, 0x01, 0x02, 0xFF]) == .map([1: 2]))
        #expect(try DeviceResponse(data: DeviceResponse().encode(options: CBOROptions())).status == 0)
    }

    private var itemPairs: [UInt8] {
        CBOR.utf8String("digestID").encode() + CBOR.unsignedInt(0).encode()
        + CBOR.utf8String("random").encode() + CBOR.byteString([1, 2]).encode()
        + CBOR.utf8String("elementIdentifier").encode() + CBOR.utf8String("name").encode()
        + CBOR.utf8String("elementValue").encode() + CBOR.utf8String("first").encode()
    }

    @Test func issuerSignedItemRejectsAmbiguityAndPreservesValidBytes() throws {
        let valid = [0xA4] + itemPairs
        let item = try IssuerSignedItem(data: valid)
        #expect(item.elementValue == .utf8String("first"))
        #expect(item.encode(options: CBOROptions()) == valid)
        let duplicate = [0xA5] + itemPairs
            + CBOR.utf8String("elementValue").encode() + CBOR.utf8String("second").encode()
        for invalid in [duplicate, valid + [0x00], valid + [0x18]] {
            #expect(throws: MdocValidationError.self) { try IssuerSignedItem(data: invalid) }
            #expect(throws: (any Error).self) {
                try CBOR.tagged(.encodedCBORDataItem, .byteString(invalid)).decodeTagged(IssuerSignedItem.self)
            }
        }
    }

    @Test func responseRejectsDuplicateStatus() {
        let bytes = [0xA3] + CBOR.utf8String("version").encode() + CBOR.utf8String("1.0").encode()
            + CBOR.utf8String("status").encode() + [0x00]
            + CBOR.utf8String("status").encode() + [0x01]
        #expect(throws: (any Error).self) { try DeviceResponse(data: bytes) }
    }

    @Test func msoRejectsTrailingBytesInsideAndOutsideTag() throws {
        let mso = try IssuerAuth(data: MdocDataModel18013Tests.AnnexdTestData.d52.bytes).mso
        let inner = mso.encode(options: CBOROptions())
        let valid = CBOR.tagged(.encodedCBORDataItem, .byteString(inner)).encode()
        #expect(try MobileSecurityObject(data: valid).digestAlgorithm == mso.digestAlgorithm)
        #expect(throws: MdocValidationError.self) { try MobileSecurityObject(data: valid + [0]) }
        #expect(throws: MdocValidationError.self) {
            try MobileSecurityObject(data: CBOR.tagged(.encodedCBORDataItem, .byteString(inner + [0])).encode())
        }
    }

    @Test func protectedHeadersRejectMalformedCBOR() throws {
        let valid: [UInt8] = [0xA1, 0x01, 0x26]
        let duplicate: [UInt8] = [0xA2, 0x01, 0x26, 0x01, 0x28]
        for bytes in [duplicate, valid + [0x00], valid + [0x18]] {
            #expect(CBOR.byteString(bytes).decodeBytestring() == nil)
            let cose = coseWithHeader(bytes)
            #expect(Cose(type: .sign1, cbor: cose) == nil)
            #expect(throws: MdocValidationError.self) { try ReaderAuth(cbor: cose) }
        }
        for bytes in [valid, [], [0xA0]] {
            let cbor = coseWithHeader(bytes)
            let cose = try #require(Cose(type: .sign1, cbor: cbor))
            #expect(cose.protectedHeader.rawHeader == .byteString(bytes))
            _ = try ReaderAuth(cbor: cbor)
        }
    }

    private func coseWithHeader(_ bytes: [UInt8]) -> CBOR {
        .array([.byteString(bytes), .map([33: .byteString([1])]), .null, .byteString([2])])
    }
}
