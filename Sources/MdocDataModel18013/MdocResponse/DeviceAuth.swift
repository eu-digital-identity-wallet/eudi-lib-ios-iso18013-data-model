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

/// contains either the DeviceSignature or the DeviceMac element
public struct DeviceAuth: Sendable {
	let coseMacOrSignature: Cose
	enum Keys: String {
		case deviceSignature
		case deviceMac
	}

	public init(coseMacOrSignature: Cose) {
		self.coseMacOrSignature = coseMacOrSignature
	}
}

extension DeviceAuth: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .map(m) = cbor else { throw .invalidCbor("Device authentication must be a map") }
		let deviceSignature = m[Keys.deviceSignature]
		let deviceMac = m[Keys.deviceMac]
		switch (deviceSignature, deviceMac) {
		case let (coseDs?, nil):
			if let dsign = Cose(type: .sign1, cbor: coseDs) { coseMacOrSignature = dsign } else { throw .invalidCbor("Device authentication invalid DeviceSignature") }
		case let (nil, coseDm?):
			if let dmac = Cose(type: .mac0, cbor: coseDm) { coseMacOrSignature = dmac } else { throw .invalidCbor("Device authentication invalid DeviceMac") }
		case (.some, .some):
			throw .invalidCbor("DeviceMac and DeviceSignature cannot both be present")
		case (nil, nil):
			throw .invalidCbor("Either DeviceMac or DeviceSignature must be present")
		}
	}
}

extension DeviceAuth: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var map = OrderedDictionary<CBOR, CBOR>()
		let cborMS = coseMacOrSignature.toCBOR(options: options)
		switch coseMacOrSignature.type {
		case .sign1: map[.utf8String(Keys.deviceSignature.rawValue)] = cborMS
		case .mac0: map[.utf8String(Keys.deviceMac.rawValue)] = cborMS
		}
		return CBOR.map(map)
	}
}
//  MacAlgorithm.swift

