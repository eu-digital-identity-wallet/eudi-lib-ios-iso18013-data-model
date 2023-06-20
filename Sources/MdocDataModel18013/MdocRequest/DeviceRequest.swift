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

extension DeviceRequest: CBORDecodable {
    init?(cbor: CBOR) {
        guard case let .map(m) = cbor else { return nil }
        guard case let .utf8String(v) = m[Keys.version] else { return nil }
        version = v
        guard case let .array(cdrs) = m[Keys.docRequests] else { return nil }
        let drs = cdrs.compactMap { DocRequest(cbor: $0) } 
        guard drs.count > 0 else { return nil }
        docRequests = drs
    }
}

extension DeviceRequest: CBOREncodable {
	func toCBOR(options: CBOROptions) -> CBOR {
		var m = [CBOR: CBOR]()
        m[.utf8String(Keys.version.rawValue)] = .utf8String(version)
        m[.utf8String(Keys.docRequests.rawValue)] = .array(docRequests.map { $0.toCBOR(options: options) })
		return .map(m)
	}
}

extension DeviceRequest {
	init(mdl items: [IsoMdlModel.CodingKeys], agesOver: [Int], intentToRetain: IntentToRetain = true) {
		var isoDataElements: [DataElementIdentifier : IntentToRetain] = Dictionary(grouping: items, by: {$0.rawValue}).mapValues {_ in intentToRetain}
		for ao in agesOver { isoDataElements["age_over_\(ao)"] = intentToRetain }
		let isoReqElements = RequestDataElements(dataElements: isoDataElements )
		let itemsReq = ItemsRequest(docType: IsoMdlModel.docType, nameSpaces: RequestNameSpaces(nameSpaces: [IsoMdlModel.namespace: isoReqElements]), requestInfo: nil)
		self.init(version: "1.0", docRequests: [DocRequest(itemsRequest: itemsReq, readerAuth: nil)])
	}
}
