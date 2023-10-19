/*
Copyright (c) 2023 European Commission

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

import XCTest
import SwiftCBOR
@testable import MdocDataModel18013

final class MdocDataModel18013Tests: XCTestCase {
	static var pkb64 = "pQECIAEhWCBoHIiBQnDRMLUT4yOLqJ1l8mrfNIgrjNnFq4RyZgxSmiJYIGD/Sabu6GejaR4eTiym1JkyjnBNcJ+f59pN+lCEyhVyI1ggC6EPCKyGci++LGWUX3fXpPFW6pYO8pyyKLMKs1qF0jo="
    static var pk = CoseKeyPrivate(base64: pkb64)!
    func testExample() throws {
        // XCTest Documenation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }

    func testDecodeDE1() throws {
        let de = try XCTUnwrap(DeviceEngagement(data: Self.AnnexdTestData.d31.bytes))
        XCTAssertEqual(de.version, "1.0")
        XCTAssertEqual(de.deviceRetrievalMethods?.first, .ble(isBleServer: false, uuid: "45EFEF742B2C4837A9A3B0E1D05A6917"))
    }
    
    func testDecodeDE2() throws {
        let de = try XCTUnwrap(DeviceEngagement(data: Self.OtherTestData.deOnline.bytes))
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

    // test based on D.4.1.1 mdoc request section of the ISO/IEC FDIS 18013-5 document
	func testDecodeDeviceRequest() throws {
		let dr = try XCTUnwrap(DeviceRequest(data: AnnexdTestData.d411.bytes))
		let testItems = ["family_name", "document_number", "driving_privileges", "issue_date", "expiry_date", "portrait"].sorted()
        XCTAssertEqual(dr.version, "1.0")
        XCTAssertEqual(dr.docRequests.first?.itemsRequest.requestNameSpaces[IsoMdlModel.isoNamespace]?.elementIdentifiers.sorted(), testItems)
		// test encode
		let cborDr = dr.toCBOR(options: CBOROptions())
		// test if successfully encoded
		let dr2 = try XCTUnwrap(DeviceRequest(cbor: cborDr))
		XCTAssertEqual(dr2.docRequests.first?.itemsRequest.requestNameSpaces["org.iso.18013.5.1"]?.elementIdentifiers.sorted(), testItems)
		// test iso make request
		let isoKeys: [IsoMdlModel.CodingKeys] = [.familyName, .documentNumber, .drivingPrivileges, .issueDate, .expiryDate, .portrait]
		let dr3 = DeviceRequest(mdl: isoKeys, agesOver: [], intentToRetain: true)
		XCTAssertEqual(dr3.docRequests.first?.itemsRequest.requestNameSpaces[IsoMdlModel.isoNamespace]?.elementIdentifiers.sorted(), testItems)
    }
	
	func testDecodeSampleDataResponse() throws {
		let dr = try XCTUnwrap(DeviceResponse(data: OtherTestData.sampleCborData.bytes))
		let pidObj = try XCTUnwrap(EuPidModel(response: dr, devicePrivateKey: Self.pk))
		XCTAssertEqual(pidObj.family_name, "ANDERSSON")
		let mdlObj = try XCTUnwrap(IsoMdlModel(response: dr, devicePrivateKey: Self.pk))
		XCTAssertEqual(mdlObj.familyName, "ANDERSSON")
	}
	
	func testMakeIsoMdlRequest() throws {
		
	}

	// test based on D.4.1.2 mdoc response section of the ISO/IEC FDIS 18013-5 document
	func testDecodeDeviceResponse() throws {
		let dr = try XCTUnwrap(DeviceResponse(data: AnnexdTestData.d412.bytes))
		XCTAssertEqual(dr.version, "1.0")
		let docs = try XCTUnwrap(dr.documents)
		let doc = try XCTUnwrap(docs.first)
		XCTAssertEqual(doc.docType, "org.iso.18013.5.1.mDL")
		let isoNS = try XCTUnwrap(doc.issuerSigned.issuerNameSpaces?["org.iso.18013.5.1"])
		let fnItem = try XCTUnwrap(isoNS.findItem(name: "family_name"))
		XCTAssertEqual(fnItem.elementValue.asString()!, "Doe")
		XCTAssertEqual(fnItem.digestID, 0)
		XCTAssertEqual(fnItem.random.toHexString().localizedUppercase, "8798645B20EA200E19FFABAC92624BEE6AEC63ACEEDECFB1B80077D22BFC20E9")
		let issuerAuth = doc.issuerSigned.issuerAuth
		XCTAssertEqual(issuerAuth.mso.deviceKeyInfo.deviceKey.x.toHexString().uppercased(), "96313D6C63E24E3372742BFDB1A33BA2C897DCD68AB8C753E4FBD48DCA6B7F9A")
		XCTAssertEqual(issuerAuth.mso.docType, "org.iso.18013.5.1.mDL")
		XCTAssertEqual(issuerAuth.mso.validityInfo.validUntil, "2021-10-01T13:30:02Z")
		let valueDigests1 = try XCTUnwrap(issuerAuth.mso.valueDigests["org.iso.18013.5.1"])
		let valueDigests2 = try XCTUnwrap(issuerAuth.mso.valueDigests["org.iso.18013.5.1.US"])
		XCTAssertEqual(valueDigests1.digestIDs.count, 13)
		XCTAssertEqual(valueDigests1[0]!.toHexString().localizedUppercase, "75167333B47B6C2BFB86ECCC1F438CF57AF055371AC55E1E359E20F254ADCEBF")
		XCTAssertEqual(valueDigests2.digestIDs.count, 4)
		XCTAssert(isoNS.count > 0)
		XCTAssertEqual(doc.deviceSigned?.nameSpacesRawData.count, 1); XCTAssertEqual(doc.deviceSigned?.nameSpacesRawData[0], 160) // {} A0 empty dic
		XCTAssertEqual(doc.deviceSigned?.deviceAuth.coseMacOrSignature.macAlgorithm, Cose.MacAlgorithm.hmac256)
		XCTAssertEqual(doc.deviceSigned?.deviceAuth.coseMacOrSignature.signature.bytes.toHexString().uppercased(), "E99521A85AD7891B806A07F8B5388A332D92C189A7BF293EE1F543405AE6824D")
		let model = try XCTUnwrap(IsoMdlModel(response: dr, devicePrivateKey: Self.pk))
		XCTAssertEqual(model.familyName, "Doe")
	}

	func testEncodeDeviceResponse() throws {
		let cborIn = try XCTUnwrap(try CBOR.decode(AnnexdTestData.d412.bytes))
		print("Input CBOR", cborIn.description, "\n\n")
		let dr = try XCTUnwrap(DeviceResponse(cbor: cborIn))
		let cborDr = dr.toCBOR(options: CBOROptions())
		print("Re-encoded CBOR", cborDr.description, "\n\n")
		
	}
    
  #if os(iOS)
    func testGenerateBLEengageQRCode() throws {
		var de = DeviceEngagement(isBleServer: true)
        var strQR = de.qrCode
        XCTAssertNotNil(de.getQrCodeImage(.m)) 
    }
  #endif

  func test_iso_date_string() {
	let df = ISO8601DateFormatter(); df.formatOptions = [.withFullDate, .withTime, .withTimeZone, .withColonSeparatorInTime, .withDashSeparatorInDate]
	let str = df.string(from: Date())
	print(str)
  }

	let ageAttestIs19 = SimpleAgeAttest(ageOver1: 21, isOver1: false, ageOver2: 60, isOver2: false)
	let ageAttestIs21 = SimpleAgeAttest(ageOver1: 21, isOver1: true, ageOver2: 60, isOver2: false)
	let ageAttestIs30 = SimpleAgeAttest(ageOver1: 21, isOver1: true, ageOver2: 60, isOver2: false)
	let ageAttestIs60 = SimpleAgeAttest(ageOver1: 21, isOver1: true, ageOver2: 60, isOver2: true)
	let ageAttestIs64 = SimpleAgeAttest(ageOver1: 21, isOver1: true, ageOver2: 60, isOver2: true)


	// test for FDIS ISO 18013-5 Table D.1 — Situations for answers to age_over_nn requests mDL holder actual age 19, 21, 30, 60, 64
  func testAgeAttest() throws {
	let testAges = [18, 19, 20, 21, 25, 30, 50, 60, 63, 64, 65]
	XCTAssertEqual(testAges.map { ageAttestIs19.isOver(age: $0)?.value }, [nil, nil, nil, false, false, false, false, false, false, false, false], "ageAttestIs19")
	XCTAssertEqual(testAges.map { ageAttestIs21.isOver(age: $0)?.value }, [true, true, true, true, nil, nil, nil, false, false, false, false], "ageAttestIs21")
	XCTAssertEqual(testAges.map { ageAttestIs30.isOver(age: $0)?.value }, [true, true, true, true, nil, nil, nil, false, false, false, false], "ageAttestIs30")
	XCTAssertEqual(testAges.map { ageAttestIs60.isOver(age: $0)?.value }, [true, true, true, true, true, true, true, true, nil, nil, nil], "ageAttestIs60")
	XCTAssertEqual(testAges.map { ageAttestIs64.isOver(age: $0)?.value }, [true, true, true, true, true, true, true, true, nil, nil, nil], "ageAttestIs64")
  }

  func testMax2AgesOver() throws {
	let testAges = [18, 19, 20, 21, 25, 30, 50, 60, 63, 64, 65]
	XCTAssertEqual(ageAttestIs19.max2AgesOverFiltered(ages: testAges), [21,25])
  }
}
