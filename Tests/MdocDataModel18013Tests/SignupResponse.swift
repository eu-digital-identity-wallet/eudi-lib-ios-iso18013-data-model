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
import SwiftCBOR
@testable import MdocDataModel18013

/// Signup response json-encoded
struct SignUpResponse: Codable, Sendable {
	let response: String?
	let pin: String?
	let privateKey: String?

	/// Device response decoded from base64-encoded string
	var deviceResponse: DeviceResponse? {
		guard let b64 = response, let d = Data(base64Encoded: b64) else { return nil }
		do {
			return try DeviceResponse(data: d.bytes)
		} catch {
            logger.error("Failed to decode device response from signup response: \(error)")
			return nil
		}
	}

	enum CodingKeys: String, CodingKey {
		case response
		case pin
		case privateKey
	}

	/// Decompose CBOR device responses from data
	///
	/// A data file may contain signup responses with many documents (doc.types).
	/// - Parameter data: Data from file or memory
	/// - Returns:  separate ``MdocDataModel18013.DeviceResponse`` objects for each doc.type
	static func decomposeCBORDeviceResponse(data: Data) -> [(docType: String, dr: DeviceResponse, iss: IssuerSigned)]? {
		guard let signupResponse = data.decodeJSON(type: SignUpResponse.self),
			  let deviceResponse = signupResponse.deviceResponse,
			  let documents = deviceResponse.documents
		else { return nil }

		return documents.map { document in
			let singleDocumentResponse = DeviceResponse(
				version: deviceResponse.version,
				documents: [document],
				status: deviceResponse.status
			)
			return (docType: document.docType, dr: singleDocumentResponse, iss: document.issuerSigned)
		}
	}

		/// Decompose CBOR signup responses from data
	///
	/// A data file may contain signup responses with many documents (doc.types).
	/// - Parameter data: Data from file or memory
	/// - Returns:  separate json serialized signup response objects for each doc.type
	public static func decomposeCBORSignupResponse(data: Data) -> [(docType: String, jsonData: Data, drData: Data, issData: Data, pkData: Data)]? {
		guard let sr = data.decodeJSON(type: MdocDataModel18013.SignUpResponse.self), let drs = decomposeCBORDeviceResponse(data: data) else { return nil }
		return drs.compactMap { sr0 -> (docType: String, jsonData: Data, drData: Data, issData: Data, pkData: Data)? in
			let drData = Data(CBOR.encode(sr0.dr.toCBOR(options: CBOROptions())))
			let issData = Data(CBOR.encode(sr0.iss.toCBOR(options: CBOROptions())))
			var jsonObj = ["response": drData.base64EncodedString()]
			guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj), let pk = sr.privateKey, let pkData = Data(base64Encoded: pk) else { return nil }
			jsonObj["privateKey"] = pk
			return (docType: sr0.docType, jsonData: jsonData, drData: drData, issData: issData, pkData: pkData)
		}
	}

}

