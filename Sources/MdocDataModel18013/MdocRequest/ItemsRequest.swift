import Foundation
import SwiftCBOR

struct ItemsRequest {
    let docType: DocType
    let nameSpaces: RequestNameSpaces
    let requestInfo: CBOR?

    enum Keys: String {
        case docType
        case nameSpaces
        case requestInfo
    }
}

extension ItemsRequest: CBORDecodable {
    init?(cbor: CBOR) {
        guard case let .map(m) = cbor else { return nil }
        guard case let .utf8String(dt) = m[Keys.docType] else { return nil }
        docType = dt
        guard let cns = m[Keys.nameSpaces], let ns = RequestNameSpaces(cbor: cns)  else { return nil }
        nameSpaces = ns
        requestInfo = m[Keys.requestInfo]
    }
}

extension ItemsRequest: CBOREncodable {
	func toCBOR(options: CBOROptions) -> CBOR {
		var m = [CBOR: CBOR]()
        m[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
        m[.utf8String(Keys.nameSpaces.rawValue)] = nameSpaces.toCBOR(options: options)
        if let requestInfo { m[.utf8String(Keys.requestInfo.rawValue)] = requestInfo }
		return .map(m)
	}
}