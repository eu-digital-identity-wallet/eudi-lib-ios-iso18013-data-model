import Foundation
import Testing
import SwiftCBOR
import OrderedCollections
@testable import MdocDataModel18013

struct SecurityFinding9Tests {
    @Test func rejectsMalformedChainsAcrossDecoders() throws {
        let issuer = try IssuerAuth(data: MdocDataModel18013Tests.AnnexdTestData.d52.bytes)
        let zk = ZkDocumentData(zkSystemSpecId: "test", docType: "test", timestamp: Date(timeIntervalSince1970: 0), issuerSigned: [:], deviceSigned: [:], msoX5chain: nil)
        var zkCbor = zk.toCBOR(options: CBOROptions())
        // Existing timestamp parser expects fractions; chain tests isolate the chain boundary.
        zkCbor["timestamp"] = .tagged(.standardDateTimeString, "2020-01-01T00:00:00.000Z")
        for chain: CBOR in [.array([]), .byteString([]), .array([.byteString([1]), .null]), .array([.byteString([])])] {
            var auth = issuer.toCBOR(options: CBOROptions())
            auth[1] = .map([33: chain])
            #expect(throws: MdocValidationError.self) { try IssuerAuth(cbor: auth) }
            #expect(throws: MdocValidationError.self) { try ReaderAuth(cbor: auth) }
            zkCbor["msoX5chain"] = chain
            #expect(throws: MdocValidationError.self) { try ZkDocumentData(cbor: zkCbor) }
        }
        for chain: CBOR in [.byteString([1]), .array([.byteString([1]), .byteString([2])])] {
            var auth = issuer.toCBOR(options: CBOROptions()); auth[1] = .map([33: chain])
            #expect(!(try IssuerAuth(cbor: auth)).x5chain.isEmpty)
            #expect(!(try ReaderAuth(cbor: auth)).x5chain.isEmpty)
            zkCbor["msoX5chain"] = chain
            #expect(!(try #require(ZkDocumentData(cbor: zkCbor).msoX5chain)).isEmpty)
        }
    }
}
