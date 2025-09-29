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

/// Contains the mdoc authentication structure and the data elements protected by mdoc authentication
public struct DeviceSigned: Sendable {
	let nameSpaces: DeviceNameSpaces
	let nameSpacesRawData: [UInt8]
	let deviceAuth: DeviceAuth
	//DeviceNameSpacesBytes = #6.24(bstr .cbor DeviceNameSpaces)
	enum Keys: String {
		case nameSpaces
		case deviceAuth
	}

	public init(deviceAuth: DeviceAuth) {
		nameSpaces = DeviceNameSpaces(deviceNameSpaces: [:])
		nameSpacesRawData = CBOR.map([:]).encode()
		self.deviceAuth = deviceAuth
	}
}

extension DeviceSigned: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(m) = cbor else { throw .deviceRequestInvalidCbor }
		guard case let .tagged(t, cdns) = m[Keys.nameSpaces], t == .encodedCBORDataItem, case let .byteString(bs) = cdns else { throw .deviceRequestInvalidCbor }
		guard let obj = try? CBOR.decode(bs) else { throw MdocValidationError.cborDecodingError }
        nameSpaces = try DeviceNameSpaces(cbor: obj)
		guard let cdu = m[Keys.deviceAuth] else { throw .deviceRequestInvalidCbor }
		deviceAuth = try DeviceAuth(cbor: cdu)
		nameSpacesRawData = bs
	}
}

extension DeviceSigned: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = OrderedDictionary<CBOR, CBOR>()
		cbor[.utf8String(Keys.nameSpaces.rawValue)] = nameSpacesRawData.taggedEncoded
		cbor[.utf8String(Keys.deviceAuth.rawValue)] = deviceAuth.toCBOR(options: options)
		return .map(cbor)
	}
}

/// Device data elements per namespac
public struct DeviceNameSpaces: Sendable {
	public let deviceNameSpaces: [NameSpace: DeviceSignedItems]
	public subscript(ns: NameSpace) -> DeviceSignedItems? { deviceNameSpaces[ns] }
}

extension DeviceNameSpaces: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(m) = cbor else { throw .deviceSignedInvalidCbor }
		let dnsPairs = try m.map { (k: CBOR, v: CBOR) throws(MdocValidationError) -> (NameSpace, DeviceSignedItems)  in
			guard case .utf8String(let ns) = k else { throw .deviceSignedInvalidCbor }
			let dsi = try DeviceSignedItems(cbor: v)
			return (ns,dsi)
		}
		let dns: [NameSpace : DeviceSignedItems] = Dictionary(dnsPairs, uniquingKeysWith: { (first, _) in first })
		deviceNameSpaces = dns
	}
}

/// Contains the data element identifiers and values for a namespace
public struct DeviceSignedItems: Sendable {
	public let deviceSignedItems: [DataElementIdentifier: DataElementValue]
	public subscript(ei: DataElementIdentifier) -> DataElementValue? { deviceSignedItems[ei] }
}

extension DeviceSignedItems: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(m) = cbor else { throw .deviceSignedInvalidCbor }
		let dsiPairs = try m.map { (k: CBOR, v: CBOR) throws(MdocValidationError) -> (DataElementIdentifier, DataElementValue)  in
			guard case .utf8String(let dei) = k else { throw .deviceSignedInvalidCbor }
			return (dei,v)
		}
		let dsi = Dictionary(dsiPairs, uniquingKeysWith: { (first, _) in first })
		if dsi.count == 0 { throw .deviceSignedInvalidCbor }
		deviceSignedItems = dsi
	}
}



