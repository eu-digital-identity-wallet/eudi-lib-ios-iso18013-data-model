import Foundation
import SwiftCBOR


/// Signup response json-encoded
public struct SignUpResponse: Codable {
	public let response: String?
	public let pin: String?
	public let privateKey: String?
	
	/// Device response decoded from base64-encoded string
	public var deviceResponse: DeviceResponse? {
		guard let b64 = response, let d = Data(base64Encoded: b64) else { return nil }
		return DeviceResponse(data: d.bytes)
	}

	/// Device private key decoded from base64-encoded string
	public var devicePrivateKey: CoseKeyPrivate? {
		guard let privateKey else { return nil }
		return CoseKeyPrivate(base64: privateKey)
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
	public static func decomposeCBORDeviceResponse(data: Data) -> [(docType: String, dr: MdocDataModel18013.DeviceResponse)]? {
		guard let sr = data.decodeJSON(type: SignUpResponse.self), let dr = sr.deviceResponse, let docs = dr.documents else { return nil }
		return docs.map { (docType: $0.docType, dr: DeviceResponse(version: dr.version, documents: [$0], status: dr.status)) }
	}
	
	/// Decompose CBOR signup responses from data
	///
	/// A data file may contain signup responses with many documents (doc.types).
	/// - Parameter data: Data from file or memory
	/// - Returns:  separate json serialized signup response objects for each doc.type
	public static func decomposeCBORSignupResponse(data: Data) -> [(docType: String, jsonData: Data)]? {
		guard let sr = data.decodeJSON(type: SignUpResponse.self), let drs = decomposeCBORDeviceResponse(data: data) else { return nil }
		return drs.compactMap {
			let response = Data(CBOR.encode($0.dr.toCBOR(options: CBOROptions()))).base64EncodedString()
			var jsonObj = ["response": response]
			if let pk = sr.privateKey { jsonObj["privateKey"] = pk }
			guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else { return nil }
			return (docType: $0.docType, jsonData: jsonData)
		}
	}
}
