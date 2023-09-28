//
//  ConnectionMethodHttp.swift
//  ScytalesDigitalWallet

import Foundation
import SwiftCBOR

public struct ConnectionMethodHttp  {
	public let uriWebsite: String
	
	public static let METHOD_TYPE: UInt64 = 4
	static let METHOD_MAX_VERSION: UInt64 = 1
	static let OPTION_KEY_URI_WEBSITE: UInt64 = 0
	
	// Creates a new connection method for REST API. @param uriWebsite the URL for the website.
	init(_ uriWebsite: String) {
		self.uriWebsite = uriWebsite
	}
}

extension ConnectionMethodHttp: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .array(arr) = cbor, arr.count == 3 else { return nil }
		guard case let .unsignedInt(type) = arr[0], case let .unsignedInt(version) = arr[1] else { return nil } // throw AppError.cbor("First two items are not numbers") }
		guard case let .map(options) = arr[2] else { return nil } // throw AppError.cbor("Third item is not a map") }
		guard type == Self.METHOD_TYPE else { return nil } // throw AppError.cbor("Unexpected method type \(type)") }
		guard version <= Self.METHOD_MAX_VERSION else { return nil } //throw AppError.cbor("Unsupported options version \(version)") }
		guard case let .utf8String(url) = options[.unsignedInt(Self.OPTION_KEY_URI_WEBSITE)] else { return nil } // throw AppError.cbor("Options does not contain uri of website") }
		self.init(url)
	}
}

extension ConnectionMethodHttp: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		.array([.unsignedInt(Self.METHOD_TYPE), .unsignedInt(Self.METHOD_MAX_VERSION), .map([.unsignedInt(Self.OPTION_KEY_URI_WEBSITE): .utf8String(uriWebsite)])])
	}
}

