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
	}
    
  #if os(iOS)
    func testGenerateBLEengageQRCode() throws {
        let de = DeviceEngagement(isBleServer: true)
        var strQR = de.qrCode
        XCTAssertNotNil(de.getQrCodeImage(.m)) 
    }
  #endif
}
