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
		guard let obj = try? CBOR.decode(data) else { throw .msoInvalidCbor }
		guard case let CBOR.tagged(tag, cborEncoded) = obj, tag == .encodedCBORDataItem, case let .byteString(bytes) = cborEncoded else { throw .msoInvalidCbor }
		guard let cbor = try? CBOR.decode(bytes) else { throw .msoInvalidCbor }
		try self.init(cbor: cbor)
	}

	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(v) = cbor else { throw .msoInvalidCbor }
		guard case let .utf8String(s) = v[Keys.version] else { throw .msoMissingField(Keys.version.rawValue) }
		version = s
		guard case let .utf8String(da) = v[Keys.digestAlgorithm] else { throw .msoMissingField(Keys.digestAlgorithm.rawValue) }
		digestAlgorithm = da
		guard let cvd = v[Keys.valueDigests] else { throw .msoMissingField(Keys.valueDigests.rawValue) }
		valueDigests = try ValueDigests(cbor: cvd)
		guard let cdki = v[Keys.deviceKeyInfo] else { throw .msoMissingField(Keys.deviceKeyInfo.rawValue) }
		deviceKeyInfo = try DeviceKeyInfo(cbor: cdki)
		guard case let .utf8String(dt) = v[Keys.docType] else { throw .msoMissingField(Keys.docType.rawValue) }
		docType = dt
		guard let cvi = v[Keys.validityInfo] else { throw .msoMissingField(Keys.validityInfo.rawValue) }
		validityInfo = try ValidityInfo(cbor: cvi)
	}
}


extension MobileSecurityObject: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = OrderedDictionary<CBOR, CBOR>()
		m[.utf8String(Keys.version.rawValue)] = .utf8String(version)
		m[.utf8String(Keys.digestAlgorithm.rawValue)] = .utf8String(digestAlgorithm)
		m[.utf8String(Keys.valueDigests.rawValue)] = valueDigests.toCBOR(options: options)
		m[.utf8String(Keys.deviceKeyInfo.rawValue)] = deviceKeyInfo.toCBOR(options: options)
		m[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
		m[.utf8String(Keys.validityInfo.rawValue)] = validityInfo.toCBOR(options: options)
		return .map(m)
	}
}
