/*
Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation
import SwiftCBOR
import OrderedCollections
/// Device retrieval mdoc request structure

/// In mDoc holder initialize a ``DeviceRequest`` with incoming CBOR bytes (decoding)
/// ```swift
/// let dr = DeviceRequest(data: bytes)
/// ```

/// In mdoc reader initialize a ``DeviceRequest`` with desired elements to read
/// ```swift
/// let isoKeys: [IsoMdlModel.CodingKeys] = [.familyName, .documentNumber, .drivingPrivileges, .issueDate, .expiryDate, .portrait]
///	let dr3 = DeviceRequest(mdl: isoKeys, agesOver: [18,21], intentToRetain: true)
/// ```
public struct DeviceRequest: Sendable {
	/// The current version
	static let version1 = "1.0"
    static let version2 = "1.1"
	/// The version requested
    public let version: String
	/// An array of all requested documents.
    public let docRequests: [DocRequest]
    /// Optional device request info (tag 24 encoded)
    public let deviceRequestInfo: DeviceRequestInfo?
    // optional reader auth all
    public let readerAuthAll: ReaderAuth?
    public let readerAuthAllRawCBOR: CBOR?

    enum Keys: String {
        case version
        case docRequests
        case deviceRequestInfo
        case readerAuthAll
    }
}

extension DeviceRequest: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(m) = cbor else { throw .invalidCbor("device request") }
        guard case let .utf8String(v) = m[Keys.version] else { throw .missingField("DeviceRequest", Keys.version.rawValue) }
        version = v
		if v.count == 0 || v.prefix(1) != "1" { throw .invalidCbor("device request") }
        guard case let .array(cdrs) = m[Keys.docRequests] else { throw .missingField("DeviceRequest", Keys.docRequests.rawValue) }
        do { docRequests = try cdrs.map { try DocRequest(cbor: $0) } } catch { throw .invalidCbor("device request") }
        guard docRequests.count > 0 else { throw .invalidCbor("device request") }
        // Decode deviceRequestInfo from tag 24 (bstr .cbor DeviceRequestInfo)
        if let deviceReqInfoValue = m[Keys.deviceRequestInfo] {
            guard case let .tagged(.encodedCBORDataItem, .byteString(bytes)) = deviceReqInfoValue,
                  let decoded = try? CBOR.decode(bytes) else { throw .invalidCbor("DeviceRequest") }
            deviceRequestInfo = try DeviceRequestInfo(cbor: decoded)
        } else { deviceRequestInfo = nil }
        if let ra = m[Keys.readerAuthAll] { readerAuthAllRawCBOR = ra; readerAuthAll = try ReaderAuth(cbor: ra) } else { readerAuthAllRawCBOR = nil; readerAuthAll = nil }
    }
}

extension DeviceRequest: CBOREncodable {
    public func encode(options: CBOROptions) -> [UInt8] { toCBOR(options: options).encode(options: options) }

	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = OrderedDictionary<CBOR, CBOR>()
        m[.utf8String(Keys.version.rawValue)] = .utf8String(version)
        m[.utf8String(Keys.docRequests.rawValue)] = .array(docRequests.map { $0.toCBOR(options: options) })
        if let deviceRequestInfo {
            let bytes = deviceRequestInfo.toCBOR(options: options).encode(options: options)
            m[.utf8String(Keys.deviceRequestInfo.rawValue)] = .tagged(.encodedCBORDataItem, .byteString(bytes))
        }
        if let readerAuthAll { m[.utf8String(Keys.readerAuthAll.rawValue)] = readerAuthAll.toCBOR(options: options) }
		return .map(m)
	}
}

extension DeviceRequest {
    /// Initialize mDoc request
    /// - Parameters:
    ///   - items: Iso specified elements to request
    ///   - agesOver: Ages to request if equal or above
    ///   - intentToRetain: Specify intent to retain (after retrieval)
	public init(mdl items: [IsoMdlModel.CodingKeys], agesOver: [Int], intentToRetain: IntentToRetain = true) {
		var isoDataElements: [DataElementIdentifier: IntentToRetain] = Dictionary(grouping: items, by: {$0.rawValue}).mapValues {_ in intentToRetain}
		for ao in agesOver { isoDataElements["age_over_\(ao)"] = intentToRetain }
		let isoReqElements = RequestDataElements(dataElements: isoDataElements )
		let itemsReq = ItemsRequest(docType: IsoMdlModel.isoDocType, requestNameSpaces: RequestNameSpaces(nameSpaces: [IsoMdlModel.isoNamespace: isoReqElements]), requestInfo: nil)
		self.init(version: Self.version1, docRequests: [DocRequest(itemsRequest: itemsReq, itemsRequestRawData: nil, readerAuth: nil, readerAuthRawCBOR: nil)], deviceRequestInfo: nil, readerAuthAll: nil, readerAuthAllRawCBOR: nil)
	}
}
