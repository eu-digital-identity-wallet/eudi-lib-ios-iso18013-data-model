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

//  KeyAuthorizations.swift

import Foundation
import SwiftCBOR
import OrderedCollections

typealias AuthorizedNameSpaces = [NameSpace]
typealias DataElementsArray = [DataElementIdentifier]
typealias AuthorizedDataElements = [NameSpace: DataElementsArray]

/// mdoc authentication public key and information related to this key.
public struct DeviceKeyInfo:Sendable {
	public let deviceKey: CoseKey
	public let keyAuthorizations: KeyAuthorizations?
	public let keyInfo: CBOR?

	enum Keys: String {
		case deviceKey
		case keyAuthorizations
		case keyInfo
	}

    public init(deviceKey: CoseKey, keyAuthorizations: KeyAuthorizations? = nil, keyInfo: CBOR? = nil) {
		self.deviceKey = deviceKey;
        self.keyAuthorizations = keyAuthorizations;
        self.keyInfo = keyInfo
	}
}

extension DeviceKeyInfo: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(cborMap) = cbor else { throw MdocValidationError.invalidCbor("device key info") }
		guard let cborDeviceKey = cborMap[Keys.deviceKey] else { throw MdocValidationError.missingField("DeviceKeyInfo", "deviceKey") }
		deviceKey = try CoseKey(cbor: cborDeviceKey)
		if let cborKeyAuthorizations = cborMap[Keys.keyAuthorizations] {
			keyAuthorizations = try KeyAuthorizations(cbor: cborKeyAuthorizations)
		} else {
			keyAuthorizations = nil
		}
		keyInfo = cborMap[Keys.keyInfo]
	}
}

extension DeviceKeyInfo: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var map = OrderedDictionary<CBOR, CBOR>()
		map[.utf8String(Keys.deviceKey.rawValue)] = deviceKey.toCBOR(options: options)
		if let keyAuthorizations { map[.utf8String(Keys.keyAuthorizations.rawValue)] = keyAuthorizations.toCBOR(options: options) }
		if let keyInfo { map[.utf8String(Keys.keyInfo.rawValue)] = keyInfo }
		return .map(map)
	}
}

/// Contains the elements the key may sign or MAC
public struct KeyAuthorizations: Sendable {
	let nameSpaces: AuthorizedNameSpaces?
	let dataElements: AuthorizedDataElements?

	enum Keys: String {
		case nameSpaces
		case dataElements
	}
}

extension KeyAuthorizations: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(cborMap) = cbor else { throw MdocValidationError.invalidCbor("key authorizations") }
		var authorizedNameSpaces: AuthorizedNameSpaces? = nil
		if case let .array(nameSpaceValues) = cborMap[Keys.nameSpaces] {
			authorizedNameSpaces = nameSpaceValues.compactMap { nameSpaceValue in
				if case let .utf8String(value) = nameSpaceValue {
					return value
				}
				return nil
			}
			if authorizedNameSpaces?.count == 0 { authorizedNameSpaces = nil }
		}
		nameSpaces = authorizedNameSpaces
		var authorizedDataElements = [NameSpace: DataElementsArray]()
		if case let .map(dataElementsMap) = cborMap[Keys.dataElements] {
			for (nameSpaceKey, nameSpaceValue) in dataElementsMap  {
				guard case let .utf8String(nameSpace) = nameSpaceKey, case let .array(dataElementValues) = nameSpaceValue else { continue }
				let dataElementIdentifiers = dataElementValues.compactMap { dataElementValue in
					if case let .utf8String(value) = dataElementValue {
						return value
					}
					return nil
				}
				guard dataElementIdentifiers.count > 0 else { continue }
				authorizedDataElements[nameSpace] = dataElementIdentifiers
			}
		}
		if authorizedDataElements.count > 0 { dataElements = authorizedDataElements } else { dataElements = nil }
	}
}

extension KeyAuthorizations: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var map = OrderedDictionary<CBOR, CBOR>()
		if let nameSpaces {
			map[.utf8String(Keys.nameSpaces.rawValue)] = .array(nameSpaces.map { .utf8String($0) })
		}
		if let dataElements {
			var dataElementsCborMap = OrderedDictionary<CBOR, CBOR>()
			for (nameSpace, dataElementIdentifiers) in dataElements { dataElementsCborMap[.utf8String(nameSpace)] = .array(dataElementIdentifiers.map { .utf8String($0) }) }
			map[.utf8String(Keys.dataElements.rawValue)] = .map(dataElementsCborMap)
		}
		return .map(map)
	}
}
