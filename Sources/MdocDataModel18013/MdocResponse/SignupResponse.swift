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

import Foundation
import SwiftCBOR

/// Signup response json-encoded
public struct SignUpResponse: Codable, Sendable {
	public let response: String?
	public let pin: String?
	public let privateKey: String?
	
	/// Device response decoded from base64-encoded string
	public var deviceResponse: DeviceResponse? {
		guard let b64 = response, let d = Data(base64Encoded: b64) else { return nil }
		return DeviceResponse(data: d.bytes)
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
	public static func decomposeCBORDeviceResponse(data: Data) -> [(docType: String, dr: DeviceResponse, iss: IssuerSigned)]? {
		guard let sr = data.decodeJSON(type: SignUpResponse.self), let dr = sr.deviceResponse, let docs = dr.documents else { return nil }
		return docs.map { (docType: $0.docType, dr: DeviceResponse(version: dr.version, documents: [$0], status: dr.status), iss: $0.issuerSigned) }
	}

}
