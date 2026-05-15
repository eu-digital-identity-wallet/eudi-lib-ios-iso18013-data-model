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

//  MdlSecurityObject.swift

import Foundation
import SwiftCBOR
import OrderedCollections

/// Mobile security object (MSO)
public struct MobileSecurityObject: Sendable {
	public let version: String
	public static let defaultVersion = "1.0"
	/// Message digest algorithm used
	public let digestAlgorithm: String
	public static let defaultDigestAlgorithmKind = DigestAlgorithmKind.SHA256
	/// Value digests
	public let valueDigests: ValueDigests
	/// device key info
	public let deviceKeyInfo: DeviceKeyInfo
	/// docType  as used in Documents
	public let docType: DocType
    /// Validity information
	public let validityInfo: ValidityInfo

	enum Keys: String {
		case version
		case digestAlgorithm
		case valueDigests
		case deviceKeyInfo
		case docType
		case validityInfo
	  }

	public init(version: String, digestAlgorithm: String, valueDigests: ValueDigests, deviceKey: CoseKey, docType: DocType, validityInfo: ValidityInfo) {
		self.version = version
		self.digestAlgorithm = digestAlgorithm
		self.valueDigests = valueDigests
		self.deviceKeyInfo = DeviceKeyInfo(deviceKey: deviceKey)
		self.docType = docType
		self.validityInfo = validityInfo
	}
}

extension MobileSecurityObject: CBORDecodable {
	public init(data: [UInt8]) throws(MdocValidationError) {
		// MobileSecurityObjectBytes = #6.24(bstr .cbor MobileSecurityObject)
		guard let obj = try? CBOR.decode(data) else { throw .invalidCbor("mobile security object") }
		guard case let CBOR.tagged(tag, encodedCbor) = obj,
			  tag == .encodedCBORDataItem,
			  case let .byteString(encodedBytes) = encodedCbor
		else { throw .invalidCbor("mobile security object") }
		guard let cbor = try? CBOR.decode(encodedBytes) else { throw .invalidCbor("mobile security object") }
		try self.init(cbor: cbor)
	}

	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(msoMap) = cbor else { throw .invalidCbor("mobile security object") }
		guard case let .utf8String(versionString) = msoMap[Keys.version] else { throw .missingField("MobileSecurityObject", Keys.version.rawValue) }
		version = versionString
		guard case let .utf8String(digestAlgorithmName) = msoMap[Keys.digestAlgorithm] else { throw .missingField("MobileSecurityObject", Keys.digestAlgorithm.rawValue) }
		digestAlgorithm = digestAlgorithmName
		guard let valueDigestsCbor = msoMap[Keys.valueDigests] else { throw .missingField("MobileSecurityObject", Keys.valueDigests.rawValue) }
		valueDigests = try ValueDigests(cbor: valueDigestsCbor)
		guard let deviceKeyInfoCbor = msoMap[Keys.deviceKeyInfo] else { throw .missingField("MobileSecurityObject", Keys.deviceKeyInfo.rawValue) }
		deviceKeyInfo = try DeviceKeyInfo(cbor: deviceKeyInfoCbor)
		guard case let .utf8String(documentType) = msoMap[Keys.docType] else { throw .missingField("MobileSecurityObject", Keys.docType.rawValue) }
		docType = documentType
		guard let validityInfoCbor = msoMap[Keys.validityInfo] else { throw .missingField("MobileSecurityObject", Keys.validityInfo.rawValue) }
		validityInfo = try ValidityInfo(cbor: validityInfoCbor)
	}
}


extension MobileSecurityObject: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var map = OrderedDictionary<CBOR, CBOR>()
		map[.utf8String(Keys.version.rawValue)] = .utf8String(version)
		map[.utf8String(Keys.digestAlgorithm.rawValue)] = .utf8String(digestAlgorithm)
		map[.utf8String(Keys.valueDigests.rawValue)] = valueDigests.toCBOR(options: options)
		map[.utf8String(Keys.deviceKeyInfo.rawValue)] = deviceKeyInfo.toCBOR(options: options)
		map[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
		map[.utf8String(Keys.validityInfo.rawValue)] = validityInfo.toCBOR(options: options)
		return .map(map)
	}
}
