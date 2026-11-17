/*
Copyright (c) 2026 European Commission

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

import Foundation
import Testing
import SwiftCBOR
@testable import MdocDataModel18013

/// The wallet sends the protected header bytes of the issuer unchanged (RFC 9052, sections 3 and 4.4).
struct IssuerAuthProtectedHeaderTests {
	private func issuerAuthCbor(protectedHeader: [UInt8]) throws -> CBOR {
		guard case var .array(items) = try #require(try CBOR.decode(MdocDataModel18013Tests.AnnexdTestData.d52.bytes)) else {
			throw MdocValidationError.invalidCbor("Test data is not a COSE_Sign1 array")
		}
		items[0] = .byteString(protectedHeader)
		return .array(items)
	}

	@Test(arguments: [
		[0xA1, 0x01, 0x26],
		[0xA2, 0x01, 0x26, 0x04, 0x42, 0x01, 0x02],
		[0xA2, 0x04, 0x42, 0x01, 0x02, 0x01, 0x26],
		[0xA2, 0x01, 0x26, 0x10, 0x63, 0x6D, 0x73, 0x6F],
	] as [[UInt8]])
	func protectedHeaderBytesAreKept(_ protectedHeader: [UInt8]) throws {
		let input = try issuerAuthCbor(protectedHeader: protectedHeader)
		let output = try IssuerAuth(cbor: input).toCBOR(options: CBOROptions())
		#expect(output.encode() == input.encode())
	}

	@Test func issuerSignedIsSentUnchanged() throws {
		let input = CBOR.map(["issuerAuth": try issuerAuthCbor(protectedHeader: [0xA2, 0x01, 0x26, 0x04, 0x42, 0x01, 0x02])]).encode()
		let issuerSigned = try IssuerSigned(cbor: try #require(try CBOR.decode(input)))
		#expect(issuerSigned.toCBOR(options: CBOROptions()).encode() == input)
	}

	@Test func newIssuerAuthHasOnlyTheAlgorithm() throws {
		let decoded = try IssuerAuth(cbor: try issuerAuthCbor(protectedHeader: [0xA1, 0x01, 0x26]))
		let created = IssuerAuth(mso: decoded.mso, msoRawData: decoded.msoRawData, verifyAlgorithm: decoded.verifyAlgorithm, signature: decoded.signature, x5chain: decoded.x5chain, statusList: decoded.statusList)
		guard case let .array(items) = created.toCBOR(options: CBOROptions()) else {
			Issue.record("Expected a COSE_Sign1 array")
			return
		}
		#expect(items[0] == .byteString([0xA1, 0x01, 0x26]))
	}
}
