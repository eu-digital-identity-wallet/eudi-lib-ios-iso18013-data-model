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

//
//  Security.swift

import Foundation
import SwiftCBOR

/// Security = [int, EDeviceKeyBytes ]
struct Security: Sendable {
	static let cipherSuiteIdentifier: UInt64 = 1
	// private key for holder only
	var d: [UInt8]?
	/// security struct. of the holder transfered (only the public key of the mDL is encoded)
	let deviceKey: CoseKey
	
#if DEBUG
	mutating func setD(d: [UInt8]) { self.d = d }
#endif
}

extension Security: CBOREncodable {
	func toCBOR(options: CBOROptions) -> CBOR {
		CBOR.array([.unsignedInt(Self.cipherSuiteIdentifier), deviceKey.taggedEncoded])
	}
}

extension Security: CBORDecodable {
	init?(cbor: CBOR) {
		guard case let .array(arr) = cbor, arr.count > 1 else { return nil }
		guard case let .unsignedInt(v) = arr[0], v == Self.cipherSuiteIdentifier else { return nil }
		guard let ck = arr[1].decodeTagged(CoseKey.self) else { return nil }
		deviceKey = ck
	}
}
