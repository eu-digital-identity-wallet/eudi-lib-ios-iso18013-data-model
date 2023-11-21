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

//
//  Security.swift

import Foundation
import SwiftCBOR

/// Security = [int, EDeviceKeyBytes ]
struct Security {
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
