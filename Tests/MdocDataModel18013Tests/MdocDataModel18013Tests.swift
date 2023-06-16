import XCTest
import SwiftCBOR
@testable import MdocDataModel18013

final class MdocDataModel18013Tests: XCTestCase {

    // ANNEX-D Test Data
    enum AnnexdTestData {
        /// D.2.1 Driving privileges
        static let d21 = Data(base64Encoded: "gqN1dmVoaWNsZV9jYXRlZ29yeV9jb2RlYUFqaXNzdWVfZGF0ZdkD7GoyMDE4LTA4LTA5a2V4cGlyeV9kYXRl2QPsajIwMjQtMTAtMjCjdXZlaGljbGVfY2F0ZWdvcnlfY29kZWFCamlzc3VlX2RhdGXZA+xqMjAxNy0wMi0yM2tleHBpcnlfZGF0ZdkD7GoyMDI0LTEwLTIw")!
        //// D.3.1  Device engagement structure QR device engagement
        static let d31 = Data(base64Encoded: "owBjMS4wAYIB2BhYS6QBAiABIVggWojRgrzl9C76WZQ/MzWdLoqWj/KJ2T5fpES2JDQxZ/4iWCCxboz4WN3HaQQHumHUwzgjeoz8895qpnL8YKVXqjL8ZwKBgwIBowD0AfULUEXv73QrLEg3qaOw4dBaaRc=")!
		/// D.5.2 Issuer data authentication
		static let d52 = Data(base64Encoded: "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")!
		// D.4.2 device response
		static let d412 = Data(base64Encoded: "o2d2ZXJzaW9uYzEuMGlkb2N1bWVudHOBo2dkb2NUeXBldW9yZy5pc28uMTgwMTMuNS4xLm1ETGxpc3N1ZXJTaWduZWSiam5hbWVTcGFjZXOhcW9yZy5pc28uMTgwMTMuNS4xhtgYWGOkaGRpZ2VzdElEAGZyYW5kb21YIIeYZFsg6iAOGf+rrJJiS+5q7GOs7t7PsbgAd9Ir/CDpcWVsZW1lbnRJZGVudGlmaWVya2ZhbWlseV9uYW1lbGVsZW1lbnRWYWx1ZWNEb2XYGFhspGhkaWdlc3RJRANmcmFuZG9tWCCyP2J+iZnHBt8MCk7ZitdK+YivYZtLsHi4kFhVP0RhXXFlbGVtZW50SWRlbnRpZmllcmppc3N1ZV9kYXRlbGVsZW1lbnRWYWx1ZdkD7GoyMDE5LTEwLTIw2BhYbaRoZGlnZXN0SUQEZnJhbmRvbVggx/+jB+Xekh5nulh4CUeH6IB6yOe1s5MtLOgPAPPpq69xZWxlbWVudElkZW50aWZpZXJrZXhwaXJ5X2RhdGVsZWxlbWVudFZhbHVl2QPsajIwMjQtMTAtMjDYGFhtpGhkaWdlc3RJRAdmcmFuZG9tWCAmBSpC5YgFV6gGwUWa8/t+tQXTeBVmMp0LYEuEW1+eaHFlbGVtZW50SWRlbnRpZmllcm9kb2N1bWVudF9udW1iZXJsZWxlbWVudFZhbHVlaTEyMzQ1Njc4OdgYWQRxpGhkaWdlc3RJRAhmcmFuZG9tWCDQlNrXZKLrnetSEOnYmWQ++9HQacwxHTKVUWygsCRBLXFlbGVtZW50SWRlbnRpZmllcmhwb3J0cmFpdGxlbGVtZW50VmFsdWVZBBL/2P/gABBKRklGAAEBAQCQAJAAAP/bAEMAEw0OEQ4MExEPERUUExcdMB8dGhodOiosIzBFPUlHRD1DQUxWbV1MUWhSQUNfgmBocXV7fHtKXIaQhXePbXh7dv/bAEMBFBUVHRkdOB8fOHZPQ092dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dnZ2dv/AABEIABgAZAMBIgACEQEDEQH/xAAbAAADAQADAQAAAAAAAAAAAAAABQYEAQIDB//EADIQAAEDAwMCBQIDCQAAAAAAAAECAwQABREGEiETMRQVUWFxIkEHgaEWNUJSc5GywfH/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")!
    }
    enum OtherTestData {
        static let deOnline = Data(base64Encoded: "pABjMS4wAYIB2BhYS6QBAiABIVggE1J1aXu4P9WmTmQqBjpJA3SPiRqQD2oR/kTiCvD5kKwiWCA5lKH1NUsQjsGoFJXU/HGq9gEaIgihxHBLjc1cYAd3QgKBgwIBowD1AfQKUAAA0pYAABAAgAAAgF+bNPsDoWZ3ZWJBcGmDAXgnaHR0cHM6Ly9hcGkucHAubW9iaWxlZGwudXMvYXBpL0lzbzE4MDEzdGVXcWJYODFCRTBMYVQxY3VtaGdo")!
    }

    func testExample() throws {
        // XCTest Documenation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }

    func testDecodeDE1() throws {
        let de = try XCTUnwrap(DeviceEngagement(data: AnnexdTestData.d31.bytes))
        XCTAssertEqual(de.version, "1.0")
        XCTAssertEqual(de.deviceRetrievalMethods?.first, .ble(isBleServer: false, uuid: "45EFEF742B2C4837A9A3B0E1D05A6917"))
    }
    
    func testDecodeDE2() throws {
        let de = try XCTUnwrap(DeviceEngagement(data: OtherTestData.deOnline.bytes))
        XCTAssertEqual(de.version, "1.0")
        XCTAssertEqual(de.deviceRetrievalMethods?.first, .ble(isBleServer: true, uuid: "0000D29600001000800000805F9B34FB"))
        XCTAssertEqual(de.serverRetrievalOptions?.webAPI, ServerRetrievalOption(url: "https://api.pp.mobiledl.us/api/Iso18013", token: "eWqbX81BE0LaT1cumhgh"))
    }
    
    func testEncodeDE() throws {
        let de1 = try XCTUnwrap(DeviceEngagement(data: OtherTestData.deOnline.bytes))
        let de1data = de1.encode(options: .init())
        XCTAssertNotNil(de1data)
    }
    
    func testDecodeDrivingPrivileges() throws {
        //test decoding according to test data
        let dps = try XCTUnwrap(DrivingPrivileges(data: AnnexdTestData.d21.bytes))
        print(dps)
        XCTAssertEqual(dps[0].vehicleCategoryCode, "A");  XCTAssertEqual(dps[0].issueDate, "2018-08-09");  XCTAssertEqual(dps[0].expiryDate, "2024-10-20")
        XCTAssertEqual(dps[1].vehicleCategoryCode, "B");  XCTAssertEqual(dps[1].issueDate, "2017-02-23");  XCTAssertEqual(dps[1].expiryDate, "2024-10-20")
        // test encoding
        let cborDps = dps.toCBOR(options: CBOROptions())
        let dps2 = try XCTUnwrap(DrivingPrivileges(cbor: cborDps))
        XCTAssertEqual(dps2[0].vehicleCategoryCode, "A");  XCTAssertEqual(dps2[0].issueDate, "2018-08-09");  XCTAssertEqual(dps2[0].expiryDate, "2024-10-20")
        XCTAssertEqual(dps2[1].vehicleCategoryCode, "B");  XCTAssertEqual(dps2[1].issueDate, "2017-02-23");  XCTAssertEqual(dps2[1].expiryDate, "2024-10-20")
    }
	
	func testDecodeIssuerAuth() throws {
		let ia = try XCTUnwrap(IssuerAuth(data: AnnexdTestData.d52.bytes))
		XCTAssertEqual(ia.mso.digestAlgorithm, "SHA-256")
		XCTAssertEqual(ia.mso.valueDigests["org.iso.18013.5.1"]?.digestIDs.count, 13)
		XCTAssertEqual(ia.mso.valueDigests["org.iso.18013.5.1.US"]?.digestIDs.count, 4)
		XCTAssertEqual(ia.mso.validityInfo.signed, "2020-10-01T13:30:02Z")
	}
	
	func testDecodeDeviceResponse() throws {
		let dr = try XCTUnwrap(DeviceResponse(data: AnnexdTestData.d412.bytes))
		XCTAssertEqual(dr.version, "1.0")
		let docs = try XCTUnwrap(dr.documents)
		let doc = try XCTUnwrap(docs.first)
		let isoNS = try XCTUnwrap(doc.issuerSigned.nameSpaces?["org.iso.18013.5.1"])
		XCTAssert(isoNS.count > 0)
	}
    
  #if os(iOS)
    func testGenerateBLEengageQRCode() throws {
        let de = DeviceEngagement(isBleServer: true)
        var strQR = de.qrCode
        XCTAssertNotNil(de.getQrCodeImage(.m)) 
    }
  #endif
}
