//
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
