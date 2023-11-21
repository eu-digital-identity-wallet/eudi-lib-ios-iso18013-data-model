 /*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */

import Foundation
import SwiftCBOR

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
public struct DeviceRequest {
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
    public init?(cbor: CBOR) {
        guard case let .map(m) = cbor else { return nil }
        guard case let .utf8String(v) = m[Keys.version] else { return nil }
        version = v
		if v.count == 0 || v.prefix(1) != "1" { return nil }
        guard case let .array(cdrs) = m[Keys.docRequests] else { return nil }
        let drs = cdrs.compactMap { DocRequest(cbor: $0) } 
        guard drs.count > 0 else { return nil }
        docRequests = drs
    }
}

extension DeviceRequest: CBOREncodable {
    public func encode(options: CBOROptions) -> [UInt8] { toCBOR(options: options).encode(options: options) }
    
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = [CBOR: CBOR]()
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
	init(mdl items: [IsoMdlModel.CodingKeys], agesOver: [Int], intentToRetain: IntentToRetain = true) {
		var isoDataElements: [DataElementIdentifier: IntentToRetain] = Dictionary(grouping: items, by: {$0.rawValue}).mapValues {_ in intentToRetain}
		for ao in agesOver { isoDataElements["age_over_\(ao)"] = intentToRetain }
		let isoReqElements = RequestDataElements(dataElements: isoDataElements )
		let itemsReq = ItemsRequest(docType: IsoMdlModel.isoDocType, requestNameSpaces: RequestNameSpaces(nameSpaces: [IsoMdlModel.isoNamespace: isoReqElements]), requestInfo: nil)
		self.init(version: "1.0", docRequests: [DocRequest(itemsRequest: itemsReq, itemsRequestRawData: nil, readerAuth: nil, readerAuthRawCBOR: nil)])
	}
}
