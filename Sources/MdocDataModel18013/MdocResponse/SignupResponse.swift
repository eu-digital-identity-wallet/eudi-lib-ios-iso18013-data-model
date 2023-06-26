import Foundation
/// Signup response encoded as base64
public struct SignUpResponse: Codable {
      public let data: String
      public var deviceResponse: DeviceResponse { DeviceResponse(data: Data(base64Encoded: data)!.bytes)!  }

      enum CodingKeys: String, CodingKey {
        case data = "Data"
      }
}
