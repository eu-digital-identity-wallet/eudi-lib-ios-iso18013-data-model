import Foundation
import SwiftCBOR


/// Signup response encoded as base64
public struct SignUpResponse: Codable {
	public let response: String?
	public let pin: String?
	public let privateKey: String?
	public var deviceResponse: DeviceResponse? {
		guard let b64 = response, let d = Data(base64Encoded: b64) else { return nil }
		return DeviceResponse(data: d.bytes)
	}

	public var devicePrivateKey: CoseKeyPrivate? {
		guard let privateKey else { return nil }
		return CoseKeyPrivate(base64: privateKey)
	}
	
	enum CodingKeys: String, CodingKey {
		case response
		case pin
		case privateKey
	}
}
