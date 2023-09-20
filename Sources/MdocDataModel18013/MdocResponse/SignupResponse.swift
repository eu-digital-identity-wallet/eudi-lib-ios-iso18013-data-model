import Foundation
import SwiftCBOR

/// Signup response encoded as base64
public struct SignUpResponse: Codable {
	public let data: String
	public let privateKey: String
	public let publicKey: String
	public var deviceResponse: DeviceResponse? {
		guard let d = Data(base64Encoded: data) else { return nil }
		return DeviceResponse(data: d.bytes)
	}
	public var devicePrivateKey: CoseKeyPrivate? { CoseKeyPrivate(base64: privateKey)	}
	
	public var devicePublicKey: CoseKey? {
		guard let d = Data(base64Encoded: publicKey) else { return nil }
		return CoseKey(data: [UInt8](d))
	}
	
	enum CodingKeys: String, CodingKey {
		case data = "Data"
		case privateKey = "PrivateKey"
		case publicKey = "PublicKey"
	}
}
