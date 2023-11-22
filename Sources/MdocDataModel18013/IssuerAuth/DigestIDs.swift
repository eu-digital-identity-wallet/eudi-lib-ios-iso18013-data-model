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

//  DigestIDs.swift

import Foundation
import SwiftCBOR

public struct DigestIDs {
	public let digestIDs: [DigestID: [UInt8]]
	public subscript(digestID: DigestID) -> [UInt8]? {digestIDs[digestID] }
	
	public init(digestIDs: [DigestID : [UInt8]]) {
		self.digestIDs = digestIDs
	}

}

extension DigestIDs: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(d) = cbor else { return nil }
		var temp = [DigestID: [UInt8]]()
		for (k,v) in d {
			if case .unsignedInt(let ui) = k, case .byteString(let ud) = v { temp[ui] = ud}
		}
		guard temp.count > 0 else  { return nil }
		digestIDs = temp
	}
}

extension DigestIDs: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = [CBOR: CBOR]()
		for (k,v) in digestIDs {
			m[.unsignedInt(k)] = .byteString(v)
		}
		return .map(m)
	}
}
