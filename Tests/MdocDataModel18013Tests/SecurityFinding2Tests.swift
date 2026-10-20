import Foundation
import Testing
import SwiftCBOR
import OrderedCollections
@testable import MdocDataModel18013

struct SecurityFinding2Tests {
    @Test func qualifiedValuesAndAges() throws {
        func item(_ name: String, _ value: CBOR) throws -> IssuerSignedItem {
            try IssuerSignedItem(cbor: ["digestID": 0, "random": .byteString([1]), "elementIdentifier": .utf8String(name), "elementValue": value])
        }
        let primary = try [item("family_name", "primary"), item("age_over_18", true)]
        let other = try [item("family_name", "other"), item("age_over_18", false)]
        let namespaces = [IsoMdlModel.isoNamespace: primary, "unrelated": other]
        let ambiguous: String? = DocClaimsModel.getCborItemValue(namespaces, string: "family_name")
        #expect(ambiguous == nil)
        #expect(SimpleAgeAttest(namespaces: namespaces).ageOverXX.isEmpty)
        #expect(SimpleAgeAttest(namespaces: namespaces, namespace: IsoMdlModel.isoNamespace).ageOverXX[18] == true)
        let auth = try IssuerAuth(data: MdocDataModel18013Tests.AnnexdTestData.d52.bytes)
        let signed = IssuerSigned(issuerNameSpaces: IssuerNameSpaces(nameSpaces: namespaces), issuerAuth: auth)
        let foreignOnly = IssuerSigned(issuerNameSpaces: IssuerNameSpaces(nameSpaces: ["unrelated": other]), issuerAuth: auth)
        let foreignName: String? = IsoMdlModel.getCborItemValue(foreignOnly, "family_name")
        #expect(foreignName == nil)
        let config = DocClaimsModelConfiguration(id: "id", docType: IsoMdlModel.isoDocType, displayName: nil, display: nil, credentialIssuerIdentifier: nil, configurationIdentifier: nil, validFrom: nil, validUntil: nil, statusList: nil, credentialsUsageCounts: nil, credentialPolicy: .rotateUse, secureAreaName: nil, modifiedAt: nil, docClaims: [], docDataFormat: .cbor, hashingAlg: nil)
        let model = try #require(IsoMdlModel(configuration: config, issuerSigned: signed, displayNames: nil, mandatory: nil))
        #expect(model.familyName == "primary")
        #expect(model.ageOverXX[18] == true)
        #expect(model.docClaims.contains { $0.namespace == "unrelated" })
        let pidSigned = IssuerSigned(issuerNameSpaces: IssuerNameSpaces(nameSpaces: [EuPidModel.euPidDocType: primary, "unrelated": other]), issuerAuth: auth)
        let pid = try #require(EuPidModel(configuration: config, issuerSigned: pidSigned, displayNames: nil, mandatory: nil))
        #expect(pid.family_name == "primary")
        #expect(pid.ageOverXX[18] == true)
    }
}
