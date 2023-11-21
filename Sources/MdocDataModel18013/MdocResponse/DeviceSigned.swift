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

/// Contains the mdoc authentication structure and the data elements protected by mdoc authentication
public struct DeviceSigned {
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
		var cbor = [CBOR: CBOR]()
		cbor[.utf8String(Keys.nameSpaces.rawValue)] = nameSpacesRawData.taggedEncoded
		cbor[.utf8String(Keys.deviceAuth.rawValue)] = deviceAuth.toCBOR(options: options)
		return .map(cbor)
	}
}

/// Device data elements per namespac
public struct DeviceNameSpaces {
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
public struct DeviceSignedItems {
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



