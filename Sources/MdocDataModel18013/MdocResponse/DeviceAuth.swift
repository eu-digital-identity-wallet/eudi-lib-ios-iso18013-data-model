//
//  DeviceAuth.swift

import Foundation
import SwiftCBOR

/// contains either the DeviceSignature or the DeviceMac element
struct DeviceAuth {
	let coseMacOrSignature: Cose
	enum	Keys: String {
		case deviceSignature
		case deviceMac
	}
}

extension DeviceAuth: CBORDecodable {
	init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		if let cs = m[Keys.deviceSignature] {
			if let ds = Cose(type: .sign1, cbor: cs) { coseMacOrSignature = ds } else { return nil }
		} else if let cm = m[Keys.deviceMac] {
			if let dm = Cose(type: .mac0, cbor: cm) { coseMacOrSignature = dm } else { return nil }
		} else { return nil }
	}
}
