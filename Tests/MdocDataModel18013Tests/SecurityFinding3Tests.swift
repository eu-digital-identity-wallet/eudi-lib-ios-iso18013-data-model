import Foundation
import Testing
import SwiftCBOR
import OrderedCollections
@testable import MdocDataModel18013

struct SecurityFinding3Tests {
    @Test func rejectsDuplicateElementsWithinNamespace() throws {
        func item(_ digest: UInt64, _ value: Bool) -> CBOR {
            let cbor: CBOR = ["digestID": .unsignedInt(digest), "random": .byteString([1]), "elementIdentifier": "age_over_18", "elementValue": .boolean(value)]
            return .tagged(.encodedCBORDataItem, .byteString(cbor.encode()))
        }
        #expect(throws: MdocValidationError.self) {
            try IssuerNameSpaces(cbor: ["ns": .array([item(0, true), item(1, false)])])
        }
        let valid = try IssuerNameSpaces(cbor: ["first": .array([item(0, true)]), "second": .array([item(1, false)])])
        #expect(valid.nameSpaces.count == 2)
    }
    @Test func rejectsDuplicateZKElements() throws {
        let data = ZkDocumentData(zkSystemSpecId: "test", docType: "test", timestamp: Date(), issuerSigned: [:], deviceSigned: [:], msoX5chain: nil)
        let element: CBOR = ["elementIdentifier": "age_over_18", "elementValue": true]
        for field in ["issuerSigned", "deviceSigned"] {
            var cbor = data.toCBOR(options: CBOROptions())
            cbor["timestamp"] = .tagged(.standardDateTimeString, "2020-01-01T00:00:00.000Z")
            cbor[.utf8String(field)] = .map(["ns": .array([element, element])])
            #expect(throws: MdocValidationError.self) { try ZkDocumentData(cbor: cbor) }
        }
    }

}
