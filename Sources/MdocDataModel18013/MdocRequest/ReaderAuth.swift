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

/// Reader authentication structure encoded as Cose Sign1
struct ReaderAuth: Sendable {
	/// encoded data
    let coseSign1: Cose
	/// one or more certificates
	let x5chain: [[UInt8]]
}

extension ReaderAuth: CBORDecodable {
    init(cbor: CBOR) throws(MdocValidationError) {
        // The signature is contained in an untagged COSE_Sign1 structure as defined in RFC 8152 and identified
        guard let cose = Cose(type: .sign1, cbor: cbor) else { throw .invalidCbor("reader authentication") }
        coseSign1 = cose
	    guard let ch = cose.unprotectedHeader?.rawHeader, case let .map(mch) = ch  else { throw .invalidCbor("reader authentication") }
		if case let .byteString(bs) = mch[.unsignedInt(33)] { x5chain = [bs] }
		else if case let .array(a) = mch[.unsignedInt(33)] { x5chain = a.compactMap { if case let .byteString(bs) = $0 { return bs } else { return nil } } }
		else { throw .invalidCbor("reader authentication") }
    }
}

extension ReaderAuth: CBOREncodable {
	func toCBOR(options: CBOROptions) -> CBOR {
        coseSign1.toCBOR(options: options)
    }
}
