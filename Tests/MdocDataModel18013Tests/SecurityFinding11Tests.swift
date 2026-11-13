import Foundation
import Testing
import SwiftCBOR
import OrderedCollections
@testable import MdocDataModel18013

struct SecurityFinding11Tests {
    @Test func bindsOuterDocumentTypeToMSO() throws {
        let response = try DeviceResponse(data: MdocDataModel18013Tests.AnnexdTestData.d412.bytes)
        let document = try #require(response.documents?.first)
        let valid = document.toCBOR(options: CBOROptions())
        #expect(try Document(cbor: valid).docType == document.issuerSigned.issuerAuth.mso.docType)
        var forged = valid
        forged["docType"] = .utf8String("different.document.type")
        #expect(throws: MdocValidationError.self) { try Document(cbor: forged) }
    }
}
