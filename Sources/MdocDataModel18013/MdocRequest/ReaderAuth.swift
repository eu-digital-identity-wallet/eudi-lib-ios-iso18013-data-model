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

import Foundation
import SwiftCBOR

/// Reader authentication structure encoded as Cose Sign1
struct ReaderAuth {
	/// encoded data
    let coseSign1: Cose
	/// one or more certificates
	let iaca: [[UInt8]] 
}

extension ReaderAuth: CBORDecodable {
    init?(cbor: CBOR) {
        // The signature is contained in an untagged COSE_Sign1 structure as defined in RFC 8152 and identified
        guard let cose = Cose(type: .sign1, cbor: cbor) else { return nil }
        coseSign1 = cose
	    guard let ch = cose.unprotectedHeader?.rawHeader, case let .map(mch) = ch  else { return nil }
		if case let .byteString(bs) = mch[.unsignedInt(33)] { iaca = [bs] }
		else if case let .array(a) = mch[.unsignedInt(33)] { iaca = a.compactMap { if case let .byteString(bs) = $0 { return bs } else { return nil } } }
		else { return nil }
    }
}

extension ReaderAuth: CBOREncodable {
	func toCBOR(options: CBOROptions) -> CBOR {
        coseSign1.toCBOR(options: options)
    }
}
