import Foundation
import SwiftCBOR

struct ItemsRequest {
    let docType: DocType
    let nameSpaces: RequestNameSpaces
    let requestInfo: [String: CBOR]?

    enum Keys: String {
        case docType
        case nameSpaces
        case requestInfo
    }
}