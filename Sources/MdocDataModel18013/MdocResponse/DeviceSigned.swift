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
	public init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		guard case let .tagged(t, cdns) = m[Keys.nameSpaces], t == .encodedCBORDataItem, case let .byteString(bs) = cdns, let dns = DeviceNameSpaces(data: bs) else { return nil }
		nameSpaces = dns
		guard let cdu = m[Keys.deviceAuth], let du = DeviceAuth(cbor: cdu) else { return nil }
		deviceAuth = du
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
	public init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		let dnsPairs = m.compactMap { (k: CBOR, v: CBOR) -> (NameSpace, DeviceSignedItems)?  in
			guard case .utf8String(let ns) = k else { return nil }
			guard let dsi = DeviceSignedItems(cbor: v) else { return nil }
			return (ns,dsi)
		}
		let dns = Dictionary(dnsPairs, uniquingKeysWith: { (first, _) in first })
		deviceNameSpaces = dns
	}
}

/// Contains the data element identifiers and values for a namespace
public struct DeviceSignedItems: Sendable {
	public let deviceSignedItems: [DataElementIdentifier: DataElementValue]
	public subscript(ei: DataElementIdentifier) -> DataElementValue? { deviceSignedItems[ei] }
}

extension DeviceSignedItems: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		let dsiPairs = m.compactMap { (k: CBOR, v: CBOR) -> (DataElementIdentifier, DataElementValue)?  in
			guard case .utf8String(let dei) = k else { return nil }
			return (dei,v)
		}
		let dsi = Dictionary(dsiPairs, uniquingKeysWith: { (first, _) in first })
		if dsi.count == 0 { return nil }
		deviceSignedItems = dsi
	}
}



