import Foundation
import SwiftCBOR

struct DocRequest {
    let itemsRequest: ItemsRequest
    let readerAuth: ReaderAuth?

    enum Keys: String {
        case itemsRequest
        case readerAuth
    }
}