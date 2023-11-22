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

/// contains either the DeviceSignature or the DeviceMac element
public struct DeviceAuth {
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
	public init?(cbor: CBOR) {
		guard case let .map(m) = cbor else { return nil }
		if let cs = m[Keys.deviceSignature] {
			if let ds = Cose(type: .sign1, cbor: cs) { coseMacOrSignature = ds } else { return nil }
		} else if let cm = m[Keys.deviceMac] {
			if let dm = Cose(type: .mac0, cbor: cm) { coseMacOrSignature = dm } else { return nil }
		} else { return nil }
	}
}

extension DeviceAuth: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m: [CBOR: CBOR] = [:]
		let cborMS = coseMacOrSignature.toCBOR(options: options)
		switch coseMacOrSignature.type {
		case .sign1: m[.utf8String(Keys.deviceSignature.rawValue)] = cborMS
		case .mac0: m[.utf8String(Keys.deviceMac.rawValue)] = cborMS
		}
		return CBOR.map(m)
	}
}
//  MacAlgorithm.swift

