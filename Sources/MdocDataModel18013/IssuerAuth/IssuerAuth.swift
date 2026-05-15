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

//  IssuerAuth.swift

import Foundation
import SwiftCBOR

public struct IssuerAuth: Sendable {
	public let mso: MobileSecurityObject
	public let msoRawData: [UInt8]
    public let statusIdentifier: StatusIdentifier?
	public let verifyAlgorithm: Cose.VerifyAlgorithm
	public let signature: Data
	public let x5chain: [[UInt8]]

	public init(mso: MobileSecurityObject, msoRawData: [UInt8], verifyAlgorithm: Cose.VerifyAlgorithm, signature: Data, x5chain: [[UInt8]], statusIdentifier: StatusIdentifier?) {
		self.mso = mso
		self.msoRawData = msoRawData
		self.verifyAlgorithm = verifyAlgorithm
		self.signature = signature
		self.x5chain = x5chain
        self.statusIdentifier = statusIdentifier
	}
}

/// Contains the mobile security object (MSO) for issuer data authentication
///
/// Encoded as `Cose` ( COSE Sign1). The payload is the MSO
extension IssuerAuth: CBORDecodable {

	public init(cbor: CBOR) throws(MdocValidationError) {
		guard let cose = Cose(type: .sign1, cbor: cbor) else { throw .invalidCbor("Issuer auth must be a Sign1 message") }
		guard case let .byteString(msoBytes) = cose.payload,
			  let verificationAlgorithm = cose.verifyAlgorithm
		else { throw .invalidCbor("Issuer auth must contain a valid payload and verification algorithm") }

		mso = try MobileSecurityObject(data: msoBytes)
		msoRawData = msoBytes
		verifyAlgorithm = verificationAlgorithm
		signature = cose.signature
		statusIdentifier = StatusIdentifier(data: msoBytes)

		guard let unprotectedHeader = cose.unprotectedHeader?.rawHeader,
			  case let .map(unprotectedHeaderMap) = unprotectedHeader
		else { throw .invalidCbor("Issuer auth must contain a valid unprotected header") }

		let x5chainHeaderKey = CBOR.unsignedInt(33)
		if case let .byteString(certificateBytes) = unprotectedHeaderMap[x5chainHeaderKey] {
			x5chain = [certificateBytes]
		}
		else if case let .array(certificateArray) = unprotectedHeaderMap[x5chainHeaderKey] {
			x5chain = try certificateArray.map { certificateItem throws(MdocValidationError) in
				if case let .byteString(certificateBytes) = certificateItem {
					return certificateBytes
				}
				throw .invalidCbor("x5chain array elements must be byte strings")
			}
		}
		else { throw .invalidCbor("Issuer auth must contain a valid x5chain") }
	}
}

extension IssuerAuth: CBOREncodable {
	public func toCBOR(options: SwiftCBOR.CBOROptions) -> SwiftCBOR.CBOR {
		let x5chainHeaderKey = CBOR.unsignedInt(33)
		let x5chainValue: CBOR = if x5chain.count == 1 {
			CBOR.byteString(x5chain[0])
		} else {
			CBOR.array(x5chain.map { CBOR.byteString($0) })
		}
		let unprotectedHeaderCbor = CBOR.map([x5chainHeaderKey: x5chainValue])
		let cose = Cose(
			type: .sign1,
			algorithm: verifyAlgorithm.rawValue,
			payloadData: Data(msoRawData),
			unprotectedHeaderCbor: unprotectedHeaderCbor,
			signature: signature
		)
		return cose.toCBOR(options: options)
	}
}




