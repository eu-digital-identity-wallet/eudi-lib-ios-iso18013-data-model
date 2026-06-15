//
//  ConnectionMethodHttp.swift
//  ScytalesDigitalWallet

import Foundation
import SwiftCBOR

public struct ConnectionMethodHttp: Sendable  {
	public let uriWebsite: String

    public enum Constants: UInt64 {
        case methodType = 4
        case methodMaxVersion = 1
        case optionKeyUriWebsite = 0
        public static let METHOD_TYPE: UInt64 = Constants.methodType.rawValue
        static let METHOD_MAX_VERSION: UInt64 = Constants.methodMaxVersion.rawValue
        static let OPTION_KEY_URI_WEBSITE: UInt64 = Constants.optionKeyUriWebsite.rawValue
    }

	// Creates a new connection method for REST API. @param uriWebsite the URL for the website.
	init(_ uriWebsite: String) {
		self.uriWebsite = uriWebsite
	}
}

extension ConnectionMethodHttp: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case let .array(arr) = cbor, arr.count == 3 else { throw .invalidCbor("Connection method is not an array of 3 items") }
		guard case let .unsignedInt(methodType) = arr[0], case let .unsignedInt(optionsVersion) = arr[1] else { throw .invalidCbor("Connection method: First two items are not numbers") }
		guard case let .map(options) = arr[2] else { throw .invalidCbor("Connection method: Third item is not a map") }
		guard methodType == Constants.METHOD_TYPE else { throw .invalidCbor("Connection method: Unexpected method type \(methodType)") }
		guard optionsVersion <= Constants.METHOD_MAX_VERSION else { throw .invalidCbor("Connection method: Unsupported options version \(optionsVersion)") }
		let websiteKey = CBOR.unsignedInt(Constants.OPTION_KEY_URI_WEBSITE)
		guard case let .utf8String(url) = options[websiteKey] else { throw .invalidCbor("Connection method: Options does not contain uri of website") }
		self.init(url)
	}
}

extension ConnectionMethodHttp: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		let websiteOptionKey = CBOR.unsignedInt(Constants.OPTION_KEY_URI_WEBSITE)
		let optionsMap: CBOR = .map([websiteOptionKey: .utf8String(uriWebsite)])
		return .array([
			.unsignedInt(Constants.METHOD_TYPE),
			.unsignedInt(Constants.METHOD_MAX_VERSION),
			optionsMap,
		])
	}
}

