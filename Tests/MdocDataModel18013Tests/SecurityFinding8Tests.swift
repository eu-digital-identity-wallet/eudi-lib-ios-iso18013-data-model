import Foundation
import Testing
import SwiftCBOR
import OrderedCollections
@testable import MdocDataModel18013

struct SecurityFinding8Tests {
    @Test func preservesProofCoveredBytes() throws {
        let data = ZkDocumentData(zkSystemSpecId: "test", docType: "test", timestamp: Date(timeIntervalSince1970: 0), issuerSigned: [:], deviceSigned: [:], msoX5chain: nil)
        var raw = data.toCBOR(options: CBOROptions())
        raw["futureExtension"] = .array([.unsignedInt(1), .utf8String("preserve me")])
        let bytes = raw.encode()
        let wire: CBOR = ["proof": .byteString([1, 2, 3]), "documentData": .tagged(.encodedCBORDataItem, .byteString(bytes))]
        let decoded = try ZkDocument(cbor: wire)
        #expect(decoded.documentDataBytes == bytes)
        #expect(decoded.toCBOR(options: CBOROptions()) == wire)
        let created = ZkDocument(documentData: data, proof: Data([4]))
        let roundtrip = try ZkDocument(cbor: created.toCBOR(options: CBOROptions()))
        #expect(roundtrip.documentDataBytes == created.documentDataBytes)
        #expect(roundtrip.proof == created.proof)
    }
}
