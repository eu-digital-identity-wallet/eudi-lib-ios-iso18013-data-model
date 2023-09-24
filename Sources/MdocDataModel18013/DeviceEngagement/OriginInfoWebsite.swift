//
//  OriginInfoWebsite.swift
//  ScytalesDigitalWallet

import Foundation
import SwiftCBOR

public struct OriginInfoWebsite {
	public static let ENGAGEMENT_VERSION_1_1 = "1.1"
	// * The constant used to specify how the current engagement structure is delivered.
	static let CAT_DELIVERY: UInt64 = 0
	// * The constant used to specify how the other party engagement structure has been received.
	static let CAT_RECEIVE: UInt64 = 1
	static let TYPE: UInt64 = 100
	private let mCat: UInt64
	private let mBaseUrl: String
	public init(baseUrl: String, cat: UInt64 = 1) {
		mCat = cat
		mBaseUrl = baseUrl
	}
}

extension OriginInfoWebsite: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		.map(["cat": .unsignedInt(mCat), "type": .unsignedInt(Self.TYPE), "Details": .map(["baseUrl": .utf8String(mBaseUrl)])])
	}
}

extension OriginInfoWebsite: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(tS) = cbor else { return nil } // throw AppError.cbor("Top-level CBOR is not an map")}
		guard case let .unsignedInt(nsCat) = tS["cat"] else { return nil } // throw AppError.cbor("cat not found")};
		guard case let .map(nsDetails) = tS["Details"], case let .utf8String(nsUrl) = nsDetails["baseUrl"] else { return nil } //throw AppError.cbor("CBOR does not contain a url field")};
		self.init(baseUrl: nsUrl, cat: nsCat)
	}
}
