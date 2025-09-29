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
	static let currentVersion = "1.0"
	/// The version requested
    public let version: String
	/// An array of all requested documents.
    public let docRequests: [DocRequest]

    enum Keys: String {
        case version
        case docRequests
    }
}

extension DeviceRequest: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(m) = cbor else { throw .invalidCbor("device request") }
        guard case let .utf8String(v) = m[Keys.version] else { throw .deviceRequestMissingField(Keys.version.rawValue) }
        version = v
		if v.count == 0 || v.prefix(1) != "1" { throw .invalidCbor("device request") }
        guard case let .array(cdrs) = m[Keys.docRequests] else { throw .deviceRequestMissingField(Keys.docRequests.rawValue) }
        do { docRequests = try cdrs.map { try DocRequest(cbor: $0) } } catch { throw .invalidCbor("device request") }
        guard docRequests.count > 0 else { throw .invalidCbor("device request") }
    }
}

extension DeviceRequest: CBOREncodable {
    public func encode(options: CBOROptions) -> [UInt8] { toCBOR(options: options).encode(options: options) }

	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = OrderedDictionary<CBOR, CBOR>()
        m[.utf8String(Keys.version.rawValue)] = .utf8String(version)
        m[.utf8String(Keys.docRequests.rawValue)] = .array(docRequests.map { $0.toCBOR(options: options) })
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
		self.init(version: "1.0", docRequests: [DocRequest(itemsRequest: itemsReq, itemsRequestRawData: nil, readerAuth: nil, readerAuthRawCBOR: nil)])
	}
}
