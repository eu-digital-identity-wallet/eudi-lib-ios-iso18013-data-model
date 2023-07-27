import Foundation
import SwiftCBOR

public struct ItemsRequest {
	/// Requested document type.
    public let docType: DocType
	/// Requested data elements for each NameSpace
    public let requestNameSpaces: RequestNameSpaces
	/// May be used by the mdoc reader to provide additional information
    let requestInfo: CBOR?

    enum Keys: String {
        case docType
        case nameSpaces
        case requestInfo
    }
}

extension ItemsRequest: CBORDecodable {
    public init?(cbor: CBOR) {
        guard case let .map(m) = cbor else { return nil }
        guard case let .utf8String(dt) = m[Keys.docType] else { return nil }
        docType = dt
        guard let cns = m[Keys.nameSpaces], let ns = RequestNameSpaces(cbor: cns)  else { return nil }
        requestNameSpaces = ns
        requestInfo = m[Keys.requestInfo]
    }
}

extension ItemsRequest: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = [CBOR: CBOR]()
        m[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
        m[.utf8String(Keys.nameSpaces.rawValue)] = requestNameSpaces.toCBOR(options: options)
        if let requestInfo { m[.utf8String(Keys.requestInfo.rawValue)] = requestInfo }
		return .map(m)
	}
}
