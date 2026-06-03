/*
Copyright (c) 2026 European Commission

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
	let deviceAuth: DeviceAuth
	//DeviceNameSpacesBytes = #6.24(bstr .cbor DeviceNameSpaces)
	enum Keys: String {
		case nameSpaces
		case deviceAuth
	}

    public init(deviceAuth: DeviceAuth, deviceNameSpaces: DeviceNameSpaces? = nil ) {
		nameSpaces = deviceNameSpaces ?? DeviceNameSpaces(deviceNameSpaces: [:])
		self.deviceAuth = deviceAuth
	}
}

extension DeviceSigned: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(m) = cbor else { throw .invalidCbor("device signed") }
		guard case let .tagged(nameSpacesTag, nameSpacesCbor) = m[Keys.nameSpaces],
			  nameSpacesTag == .encodedCBORDataItem,
			  case let .byteString(nameSpacesBytes) = nameSpacesCbor
		else { throw .missingField("DeviceSigned", Keys.nameSpaces.rawValue) }

		let bs = nameSpacesBytes
		guard let obj = try? CBOR.decode(bs) else { throw MdocValidationError.cborDecodingError }
        nameSpaces = try DeviceNameSpaces(cbor: obj)
		guard let cdu = m[Keys.deviceAuth] else { throw .missingField("DeviceSigned", Keys.deviceAuth.rawValue) }
		deviceAuth = try DeviceAuth(cbor: cdu)
	}
}

extension DeviceSigned: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = OrderedDictionary<CBOR, CBOR>()
        cbor[.utf8String(Keys.nameSpaces.rawValue)] = nameSpaces.toCBOR(options: options).taggedEncoded
		cbor[.utf8String(Keys.deviceAuth.rawValue)] = deviceAuth.toCBOR(options: options)
		return .map(cbor)
	}
}

/// Device data elements per namespac
public struct DeviceNameSpaces: Sendable {
	public let deviceNameSpaces: OrderedDictionary<NameSpace, DeviceSignedItems>
	public subscript(ns: NameSpace) -> DeviceSignedItems? { deviceNameSpaces[ns] }
}

extension DeviceNameSpaces: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(m) = cbor else { throw .invalidCbor("device signed") }
		var orderedDeviceSignedNamespaces = OrderedDictionary<NameSpace, DeviceSignedItems>()
		for (k, v) in m {
			guard case .utf8String(let ns) = k else { throw .invalidCbor("Invalid device signed namespace") }
			orderedDeviceSignedNamespaces[ns] = try DeviceSignedItems(cbor: v)
		}
		deviceNameSpaces = orderedDeviceSignedNamespaces
	}
}

extension DeviceNameSpaces: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        .map(deviceNameSpaces.reduce(into: OrderedDictionary<CBOR, CBOR>()) { cbor, pair in
            cbor[.utf8String(pair.key)] = pair.value.toCBOR(options: options)
        })
    }
}

/// Contains the data element identifiers and values for a namespace
public struct DeviceSignedItems: Sendable {
	public let deviceSignedItems: OrderedDictionary<DataElementIdentifier, DataElementValue>
	public subscript(ei: DataElementIdentifier) -> DataElementValue? { deviceSignedItems[ei] }
}

extension DeviceSignedItems: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(m) = cbor else { throw .invalidCbor("device signed") }
		var orderedDataElements = OrderedDictionary<DataElementIdentifier, DataElementValue>()
		for (k, v) in m {
			guard case .utf8String(let dei) = k else { throw .invalidCbor("Invalid device signed item") }
			orderedDataElements[dei] = v
		}
		guard !orderedDataElements.isEmpty else { throw .invalidCbor("device signed empty array") }
		deviceSignedItems = orderedDataElements
	}
}

extension DeviceSignedItems: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        .map(deviceSignedItems.reduce(into: OrderedDictionary<CBOR, CBOR>()) { cbor, pair in
            cbor[.utf8String(pair.key)] = pair.value
        })
    }
}



