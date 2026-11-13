import Foundation
import SwiftCBOR
import Testing
@testable import MdocDataModel18013

struct ClaimDescriptionPrivacyTests {
    private func expectRedacted<T>(_ value: T, type: String) {
        #expect(String(describing: value) == "\(type)(<redacted>)")
        #expect(String(reflecting: value) == "\(type)(<redacted>)")
        #expect("\(value)" == "\(type)(<redacted>)")
    }

    @Test func cborDescriptionsRedactScalarsAndNestedContainers() {
        let values: [CBOR] = [
            .utf8String("Jane Privacy"), .unsignedInt(123456789), .boolean(true),
            .simple(42), .double(123.45), .negativeInt(99),
            .tagged(CBOR.Tag(rawValue: 1004), .utf8String("1990-01-02")),
            .byteString(Array("portrait-canary".utf8)),
            .map([.utf8String("sensitive-key"): .array([.utf8String("secret-value")])])
        ]
        for value in values {
            expectRedacted(value, type: "CBOR")
        }
        #expect(CBOR.utf8String("Jane Privacy").displayString == "Jane Privacy")
        #expect(CBOR.unsignedInt(123456789).displayString == "123456789")
        #expect(CBOR.boolean(true).displayString == "true")
        #expect(CBOR.tagged(CBOR.Tag(rawValue: 1004), .utf8String("1990-01-02")).displayString == "1990-01-02")
        let nested: CBOR = .map([.utf8String("sensitive-key"): .array([.utf8String("secret-value")])])
        #expect(nested.detailedDisplayString == "{ 'sensitive-key': [ 'secret-value']}")
    }

    @Test func issuerSignedItemDescriptionsRedactClaims() throws {
        let item = try IssuerSignedItem(cbor: .map([
            .utf8String("digestID"): .unsignedInt(0),
            .utf8String("random"): .byteString([1, 2, 3]),
            .utf8String("elementIdentifier"): .utf8String("family_name"),
            .utf8String("elementValue"): .utf8String("Privacy Canary")
        ]))
        expectRedacted(item, type: "IssuerSignedItem")
        #expect(item.displayString == "Privacy Canary")
        #expect(item.detailedDisplayString == "'Privacy Canary'")
        #expect(item.elementValue == .utf8String("Privacy Canary"))
    }

    @Test func docClaimDescriptionsRedactValuesAndMetadata() {
        let claim = DocClaim(name: "sensitive-name", displayName: "sensitive-label", dataValue: .string("secret"), stringValue: "secret", order: 42)
        expectRedacted(claim, type: "DocClaim")
        #expect(claim.displayString == "secret")
    }

    @Test func dataValueDescriptionsRedactBinaryAndScalarValues() {
        let bytes = Array("portrait-canary".utf8)
        let values: [DocDataValue] = [.boolean(true), .integer(123), .double(1.5), .string("secret"), .date("1990-01-02"), .bytes(bytes), .array, .dictionary]
        for value in values {
            expectRedacted(value, type: "DocDataValue")
        }
        #expect(DocDataValue.string("secret").displayString == "secret")
        #expect(DocDataValue.date("1990-01-02").displayString == "1990-01-02")
        #expect(DocDataValue.bytes(bytes).displayString == "Bytes \(bytes.count)")
        #expect(DocDataValue.bytes(bytes).detailedDisplayString == Data(bytes).base64EncodedString())
        #expect(DocDataValue.bytes(bytes).base64 == Data(bytes).base64EncodedString())
    }

    @Test func claimExtractionPreservesNormalAndDetailedDisplay() {
        for detailed in [false, true] {
            let claim = IsoMdlModel.extractCborClaim("family_name", ["family_name"], .utf8String("Privacy Canary"), detailed, "org.iso.18013.5.1", 0)
            #expect(claim.stringValue == (detailed ? "'Privacy Canary'" : "Privacy Canary"))
            #expect(claim.dataValue == .string("Privacy Canary"))
            expectRedacted(claim, type: "DocClaim")
        }
        let nested: CBOR = .map([.utf8String("child"): .utf8String("secret")])
        let claim = IsoMdlModel.extractCborClaim("parent", ["parent"], nested, true, "org.iso.18013.5.1", 0)
        #expect(claim.stringValue == "{ 'child': 'secret'}")
        #expect(claim.children?.first?.stringValue == "'secret'")
        let sex = IsoMdlModel.extractCborClaim("sex", ["sex"], .unsignedInt(1), false, "org.iso.18013.5.1", 0)
        #expect(sex.stringValue == NSLocalizedString("male", comment: ""))
    }
}
