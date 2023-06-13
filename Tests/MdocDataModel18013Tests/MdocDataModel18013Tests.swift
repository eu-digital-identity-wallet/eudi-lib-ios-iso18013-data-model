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
    
  #if os(iOS)
    func testGenerateBLEengageQRCode() throws {
        let de = DeviceEngagement(isBleServer: true)
        var strQR = de.qrCode
        XCTAssertNotNil(de.getQrCodeImage(.m)) 
    }
  #endif
}
