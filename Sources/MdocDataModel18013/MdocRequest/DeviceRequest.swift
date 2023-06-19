import Foundation
import SwiftCBOR

struct DeviceRequest {
    let version: String
    let docRequests: [DocRequest]

    enum Keys: String {
        case version
        case docRequests
    }
}

