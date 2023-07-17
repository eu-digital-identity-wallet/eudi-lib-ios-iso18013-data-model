//
//  MdlSecurityObject.swift

import Foundation
import SwiftCBOR

/// Mobile security object (MSO)
public struct MobileSecurityObject {
	public let version: String
	/// Message digest algorithm used
	public let digestAlgorithm: String
	/// Value digests
	public let valueDigests: ValueDigests
	/// device key info
	let deviceKeyInfo: DeviceKeyInfo
	/// docType  as used in Documents
	public let docType: DocType
	public let validityInfo: ValidityInfo
	
	enum Keys: String {
		case version
		case digestAlgorithm
		case valueDigests
		case deviceKeyInfo
		case docType
		case validityInfo
	  }
}

extension MobileSecurityObject: CBORDecodable {
	public init?(data: [UInt8]) {
		// MobileSecurityObjectBytes = #6.24(bstr .cbor MobileSecurityObject)
		guard let obj = try? CBOR.decode(data) else { return nil }
		guard case let CBOR.tagged(tag, cborEncoded) = obj, tag.rawValue == 24, case let .byteString(bytes) = cborEncoded else { return nil }
		guard let cbor = try? CBOR.decode(bytes) else { return nil }
		self.init(cbor: cbor)
	}

	public init?(cbor: CBOR) {
		guard case let .map(v) = cbor else { return nil }
		guard case let .utf8String(s) = v[Keys.version] else { return nil }
		version = s
		guard case let .utf8String(da) = v[Keys.digestAlgorithm] else { return nil }
		digestAlgorithm = da
		guard let cvd = v[Keys.valueDigests], let vd = ValueDigests(cbor: cvd) else { return nil }
		valueDigests = vd
		guard let cdki = v[Keys.deviceKeyInfo], let dki = DeviceKeyInfo(cbor: cdki) else { return nil }
		deviceKeyInfo = dki
		guard case let .utf8String(dt) = v[Keys.docType] else { return nil }
		docType = dt
		guard let cvi = v[Keys.validityInfo], let vi = ValidityInfo(cbor: cvi) else { return nil }
		validityInfo = vi
	}
}
