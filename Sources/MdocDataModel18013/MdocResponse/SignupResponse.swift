import Foundation
/// Signup response encoded as base64
public struct SignUpResponse: Codable {
      public let data: String
      public var deviceResponse: DeviceResponse? {
		  guard let d = Data(base64Encoded: data) else { return nil }
		  return DeviceResponse(data: d.bytes)
	  }

      enum CodingKeys: String, CodingKey {
        case data = "Data"
      }
}
