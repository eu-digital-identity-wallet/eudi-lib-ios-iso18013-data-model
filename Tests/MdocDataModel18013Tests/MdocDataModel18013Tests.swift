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

import Testing
import Foundation
import SwiftCBOR
import OrderedCollections
@testable import MdocDataModel18013

struct MdocDataModel18013Tests {
	static let pkb64 = "pQECIAEhWCBoHIiBQnDRMLUT4yOLqJ1l8mrfNIgrjNnFq4RyZgxSmiJYIGD/Sabu6GejaR4eTiym1JkyjnBNcJ+f59pN+lCEyhVyI1ggC6EPCKyGci++LGWUX3fXpPFW6pYO8pyyKLMKs1qF0jo="
    static let pk = CoseKeyPrivate(p256data: pkb64)!

    @Test func basicExample() throws {
        // Swift Testing Documentation
        // https://developer.apple.com/documentation/testing
    }

    @Test func decodeDE1() throws {
        let de = try DeviceEngagement(data: Self.AnnexdTestData.d31.bytes)
        #expect(de.version == "1.0")
        #expect(de.deviceRetrievalMethods?.first == .ble(isBleServer: false, uuid: UUID(uuidString: "45EFEF74-2B2C-4837-A9A3-B0E1D05A6917")!))
    }

    @Test func decodeDE2() throws {
        let de = try DeviceEngagement(data: Self.OtherTestData.deOnline.bytes)
        #expect(de.version == "1.0")
        #expect(de.deviceRetrievalMethods?.first == .ble(isBleServer: true, uuid: UUID(uuidString: "0000D296-0000-1000-8000-00805F9B34FB")!))
        #expect(de.serverRetrievalOptions?.webAPI == ServerRetrievalOption(url: "https://api.pp.mobiledl.us/api/Iso18013", token: "eWqbX81BE0LaT1cumhgh"))
    }

    @Test func encodeDE() throws {
        let de1 = try DeviceEngagement(data: OtherTestData.deOnline.bytes)
        let de1data = de1.encode(options: CBOROptions())
        #expect(!de1data.isEmpty)
    }

    @Test func decodeDrivingPrivileges() throws {
        //test decoding according to test data
        let dps = try DrivingPrivileges(data: AnnexdTestData.d21.bytes)
        #expect(dps[0].vehicleCategoryCode == "A");  #expect(dps[0].issueDate == "2018-08-09");  #expect(dps[0].expiryDate == "2024-10-20")
        #expect(dps[1].vehicleCategoryCode == "B");  #expect(dps[1].issueDate == "2017-02-23");  #expect(dps[1].expiryDate == "2024-10-20")
        // test encoding
        let cborDps = dps.toCBOR(options: CBOROptions())
        let dps2 = try DrivingPrivileges(cbor: cborDps)
        #expect(dps2[0].vehicleCategoryCode == "A");  #expect(dps2[0].issueDate == "2018-08-09");  #expect(dps2[0].expiryDate == "2024-10-20")
        #expect(dps2[1].vehicleCategoryCode == "B");  #expect(dps2[1].issueDate == "2017-02-23");  #expect(dps2[1].expiryDate == "2024-10-20")
    }

	@Test func decodeIssuerAuth() throws {
		let ia = try IssuerAuth(data: AnnexdTestData.d52.bytes)
		#expect(ia.mso.digestAlgorithm == "SHA-256")
		#expect(ia.mso.valueDigests[IsoMdlModel.isoNamespace]?.digestIDs.count == 13)
		#expect(ia.mso.valueDigests["org.iso.18013.5.1.US"]?.digestIDs.count == 4)
		#expect(ia.mso.validityInfo.signed == "2020-10-01T13:30:02Z")
	}

    // test based on D.4.1.1 mdoc request section of the ISO/IEC FDIS 18013-5 document
	@Test func decodeDeviceRequest() throws {
		let dr = try DeviceRequest(data: AnnexdTestData.d411.bytes)
		let testItems = ["family_name", "document_number", "driving_privileges", "issue_date", "expiry_date", "portrait"].sorted()
        #expect(dr.version == "1.0")
        #expect(dr.docRequests.first?.itemsRequest.requestNameSpaces[IsoMdlModel.isoNamespace]?.elementIdentifiers.sorted() == testItems)
		// test encode
		let cborDr = dr.toCBOR(options: CBOROptions())
		// test if successfully encoded
		let dr2 = try DeviceRequest(cbor: cborDr)
		#expect(dr2.docRequests.first?.itemsRequest.requestNameSpaces[IsoMdlModel.isoNamespace]?.elementIdentifiers.sorted() == testItems)
		// test iso make request
		let isoKeys: [IsoMdlModel.CodingKeys] = [.familyName, .documentNumber, .drivingPrivileges, .issueDate, .expiryDate, .portrait]
		let dr3 = DeviceRequest(mdl: isoKeys, agesOver: [], intentToRetain: true)
		#expect(dr3.docRequests.first?.itemsRequest.requestNameSpaces[IsoMdlModel.isoNamespace]?.elementIdentifiers.sorted() == testItems)
	}

	@Test func decodeSampleDataResponse() throws {
		let eudiSampleData = Data(name: "EUDI_sample_data", ext: "json", from: Bundle.module)!
		let sr = try #require(eudiSampleData.decodeJSON(type: SignUpResponse.self))
		let dr = try #require(sr.deviceResponse)
		let docs = try #require(dr.documents)
	  	let d1 = try #require(docs.first(where: {$0.docType == EuPidModel.euPidDocType}))
		let d2 = try #require(docs.first(where: {$0.docType == IsoMdlModel.isoDocType}))
		//let ns1 = d1?.issuerSigned.issuerNameSpaces!.nameSpaces.first
		let pidObj = try #require(EuPidModel(id: UUID().uuidString, createdAt: Date(), issuerSigned: d1.issuerSigned, displayName: "PID", display: nil, issuerDisplay: nil, credentialIssuerIdentifier: nil, configurationIdentifier: nil, validFrom: d1.issuerSigned.validFrom, validUntil: d1.issuerSigned.validUntil, statusIdentifier: d1.issuerSigned.issuerAuth.statusIdentifier, credentialsUsageCounts: nil, credentialPolicy: .rotateUse, secureAreaName: nil, displayNames: nil, mandatory: nil))
		#expect(pidObj.family_name == "ANDERSSON")
		let mdlObj = try #require(IsoMdlModel(id: UUID().uuidString, createdAt: Date(), issuerSigned: d2.issuerSigned, displayName: "mDL", display: nil, issuerDisplay: nil, credentialIssuerIdentifier: nil, configurationIdentifier: nil, validFrom: d1.issuerSigned.validFrom, validUntil: d1.issuerSigned.validUntil, statusIdentifier: d1.issuerSigned.issuerAuth.statusIdentifier, credentialsUsageCounts: nil, credentialPolicy: .rotateUse, secureAreaName: nil, displayNames: nil, mandatory: nil))
		#expect(mdlObj.familyName == "ANDERSSON")
		printDisplayStrings(mdlObj.docClaims)
	}

	func printDisplayStrings(_ displayStrings: [DocClaim], level: Int = 0) {
		for ns in displayStrings {
			for _ in 0..<level { print(" ", terminator: "") }
			print(ns.order, ":", ns.name, ns.stringValue)
			// display children
			if let children = ns.children {
				printDisplayStrings(children, level: level + 1)
			}
		}
	}

	// test based on D.4.1.2 mdoc response section of the ISO/IEC FDIS 18013-5 document
	@Test func decodeDeviceResponse() throws {
		let dr = try DeviceResponse(data: AnnexdTestData.d412.bytes)
		#expect(dr.version == "1.0")
		let docs = try #require(dr.documents)
		let doc = try #require(docs.first)
		#expect(doc.docType == IsoMdlModel.isoDocType)
		let isoNS = try #require(doc.issuerSigned.issuerNameSpaces?[IsoMdlModel.isoNamespace])
		let fnItem = try #require(isoNS.findItem(name: "family_name"))
		#expect(fnItem.elementValue.asString()! == "Doe")
		#expect(fnItem.digestID == 0)
		#expect(fnItem.random.toHexString().localizedUppercase == "8798645B20EA200E19FFABAC92624BEE6AEC63ACEEDECFB1B80077D22BFC20E9")
		let issuerAuth = doc.issuerSigned.issuerAuth
		#expect(issuerAuth.mso.deviceKeyInfo.deviceKey.x.toHexString().uppercased() == "96313D6C63E24E3372742BFDB1A33BA2C897DCD68AB8C753E4FBD48DCA6B7F9A")
		#expect(issuerAuth.mso.docType == IsoMdlModel.isoDocType)
		#expect(issuerAuth.mso.validityInfo.validUntil == "2021-10-01T13:30:02Z")
		let valueDigests1 = try #require(issuerAuth.mso.valueDigests[IsoMdlModel.isoNamespace])
		let valueDigests2 = try #require(issuerAuth.mso.valueDigests["org.iso.18013.5.1.US"])
		#expect(valueDigests1.digestIDs.count == 13)
		#expect(valueDigests1[0]!.toHexString().localizedUppercase == "75167333B47B6C2BFB86ECCC1F438CF57AF055371AC55E1E359E20F254ADCEBF")
		#expect(valueDigests2.digestIDs.count == 4)
		#expect(isoNS.count > 0)
		#expect(doc.deviceSigned.nameSpacesRawData.count == 1); #expect(doc.deviceSigned.nameSpacesRawData[0] == 160) // {} A0 empty dic
		#expect(doc.deviceSigned.deviceAuth.coseMacOrSignature.macAlgorithm == Cose.MacAlgorithm.hmac256)
		#expect(doc.deviceSigned.deviceAuth.coseMacOrSignature.signature.bytes.toHexString().uppercased() == "E99521A85AD7891B806A07F8B5388A332D92C189A7BF293EE1F543405AE6824D")
        let d1 = dr.documents!.first!
		let model = try #require(IsoMdlModel(id: UUID().uuidString, createdAt: Date(), issuerSigned: d1.issuerSigned, displayName: "PID", display: nil, issuerDisplay: nil, credentialIssuerIdentifier: nil, configurationIdentifier: nil, validFrom: d1.issuerSigned.validFrom, validUntil: d1.issuerSigned.validUntil, statusIdentifier: d1.issuerSigned.issuerAuth.statusIdentifier, credentialsUsageCounts: nil, credentialPolicy: .rotateUse, secureAreaName: nil, displayNames: nil, mandatory: nil))
		#expect(model.familyName == "Doe")
	}

	@Test func encodeDeviceResponse() throws {
		let cborIn = try #require(try CBOR.decode(AnnexdTestData.d412.bytes))
		let dr = try DeviceResponse(cbor: cborIn)
		let cborDr = dr.toCBOR(options: CBOROptions())
        // test if successfully encoded
        let dr2 = try DeviceResponse(cbor: cborDr)
        #expect(dr2.version == "1.0")
	}

  #if os(iOS)
    @Test func generateBLEengageQRCodeImage() async throws {
        var de = try DeviceEngagement(isBleServer: true)
        try await de.makePrivateKey(crv: .P256, secureArea: InMemoryP256SecureArea(storage: DummySecureKeyStorage()))
        #expect(de.getQrCodePayload() != nil)
        let strQR = de.qrCode
		#expect(DeviceEngagement.getQrCodeImage(qrCode: strQR, inputCorrectionLevel: .m) != nil)
    }

    @Test func generateBLEengageQRCodePayload() async throws {
        var de = try DeviceEngagement(isBleServer: true)
        try await de.makePrivateKey(crv: .P256, secureArea: InMemoryP256SecureArea(storage: DummySecureKeyStorage()))
        #expect(de.getQrCodePayload() != nil)
    }
  #endif

  @Test func isoDateString() {
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
	@Test func ageAttest() throws {
		let testAges = [18, 19, 20, 21, 25, 30, 50, 60, 63, 64, 65]
		#expect(testAges.map { ageAttestIs19.isOver(age: $0)?.value } == [nil, nil, nil, false, false, false, false, false, false, false, false])
		#expect(testAges.map { ageAttestIs21.isOver(age: $0)?.value } == [true, true, true, true, nil, nil, nil, false, false, false, false])
		#expect(testAges.map { ageAttestIs30.isOver(age: $0)?.value } == [true, true, true, true, nil, nil, nil, false, false, false, false])
		#expect(testAges.map { ageAttestIs60.isOver(age: $0)?.value } == [true, true, true, true, true, true, true, true, nil, nil, nil])
		#expect(testAges.map { ageAttestIs64.isOver(age: $0)?.value } == [true, true, true, true, true, true, true, true, nil, nil, nil])
	}

	@Test func max2AgesOver() throws {
		let testAges = [18, 19, 20, 21, 25, 30, 50, 60, 63, 64, 65]
		#expect(ageAttestIs19.max2AgesOverFiltered(ages: testAges) == [21,25])
	}

	@Test func filterMoreThan2AgeOverElementRequests() throws {
		let dr = try DeviceResponse(data: AnnexdTestData.d412.bytes)
		let docs = try #require(dr.documents); let doc = try #require(docs.first)
		#expect(doc.docType == IsoMdlModel.isoDocType)
		_ = try #require(doc.issuerSigned.issuerNameSpaces)
		let tmp = IsoMdlModel.self.moreThan2AgeOverElementIdentifiers(IsoMdlModel.isoDocType, IsoMdlModel.isoNamespace, ageAttestIs19, ["birth_date", "age_over_18", "age_over_21", "age_over_60"])
		#expect(tmp == ["age_over_18"])
	}

	@Test func joinSampleDeviceResponses() throws {
		let mdlData = Data(base64Encoded: String(data: Data(name: "mdl_b64", ext: "txt", from: Bundle.module)!, encoding: .utf8)!)!
		let pidData = Data(base64Encoded: String(data: Data(name: "pid_b64", ext: "txt", from: Bundle.module)!, encoding: .utf8)!)!
		let drMdl = try DeviceResponse(data: [UInt8](mdlData))
		let drPid = try DeviceResponse(data: [UInt8](pidData))
		let drSample = DeviceResponse(version: drPid.version, documents: drMdl.documents! + drPid.documents!,
			documentErrors: nil, status: drPid.status)
        #expect(drSample.documents!.count == 2)
	}

	@Test func uuidFromBytes() {
		let bs: [UInt8] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F]
		let uuid = NSUUID(uuidBytes: bs)
		#expect(uuid.uuidString == "00010203-0405-0607-0809-0a0b0c0d0e0f".uppercased())
	}

	@Test func urlHost() {
		let url = URL(string: "https://api.pp.mobiledl.us/api/Iso18013")!
		#expect(url.host == "api.pp.mobiledl.us")
	}
}
