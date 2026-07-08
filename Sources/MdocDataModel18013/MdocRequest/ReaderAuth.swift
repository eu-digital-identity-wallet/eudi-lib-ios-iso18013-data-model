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

/// Reader authentication structure encoded as Cose Sign1
public struct ReaderAuth: Sendable {
	/// encoded data
    let coseSign1: Cose
	/// one or more certificates
	public let x5chain: [[UInt8]]
}

extension ReaderAuth: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        // The signature is contained in an untagged COSE_Sign1 structure as defined in RFC 8152 and identified
        guard let cose = Cose(type: .sign1, cbor: cbor) else { throw .invalidCbor("reader authentication") }
        coseSign1 = cose
        guard let unprotectedHeader = cose.unprotectedHeader?.rawHeader,
              case let .map(unprotectedHeaderMap) = unprotectedHeader
        else { throw .invalidCbor("reader authentication") }

        let x5chainHeaderKey = CBOR.unsignedInt(33)
        if case let .byteString(certificateBytes) = unprotectedHeaderMap[x5chainHeaderKey] {
            x5chain = [certificateBytes]
        }
        else if case let .array(certificateArray) = unprotectedHeaderMap[x5chainHeaderKey] {
            x5chain = certificateArray.compactMap { certificateEntry in
                if case let .byteString(certificateBytes) = certificateEntry {
                    return certificateBytes
                }
                return nil
            }
        }
		else { throw .invalidCbor("reader authentication") }
    }
}

extension ReaderAuth: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
        coseSign1.toCBOR(options: options)
    }
}
