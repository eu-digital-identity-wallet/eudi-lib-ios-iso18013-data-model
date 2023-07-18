//
//  KeyAuthorizations.swift

import Foundation
import SwiftCBOR

typealias AuthorizedNameSpaces = [NameSpace]
typealias DataElementsArray = [DataElementIdentifier]
typealias AuthorizedDataElements = [NameSpace: DataElementsArray]

/// mdoc authentication public key and information related to this key.
public struct DeviceKeyInfo {
	public let deviceKey: CoseKey
	let keyAuthorizations: KeyAuthorizations?
	let keyInfo: CBOR?
	
	enum Keys: String {
		case deviceKey
		case keyAuthorizations
		case keyInfo
	}
	
	public init(deviceKey: CoseKey) {
		self.deviceKey = deviceKey; self.keyAuthorizations = nil; self.keyInfo = nil
	}
}

extension DeviceKeyInfo: CBORDecodable {
	public init?(cbor: CBOR) {
		guard case let .map(v) = cbor else { return nil }
		guard let cdk = v[Keys.deviceKey], let dk = CoseKey(cbor: cdk) else { return nil }
		deviceKey = dk
		if let cka = v[Keys.keyAuthorizations], let ka = KeyAuthorizations(cbor: cka) { keyAuthorizations = ka } else { keyAuthorizations = nil }
		keyInfo = v[Keys.keyInfo]
	}
}

extension DeviceKeyInfo: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = [CBOR: CBOR]()
		m[.utf8String(Keys.deviceKey.rawValue)] = deviceKey.toCBOR(options: options)
		if let keyAuthorizations { m[.utf8String(Keys.keyAuthorizations.rawValue)] = keyAuthorizations.toCBOR(options: options) }
		if let keyInfo { m[.utf8String(Keys.keyInfo.rawValue)] = keyInfo }
		return .map(m)
	}
}

/// Contains the elements the key may sign or MAC
struct KeyAuthorizations {
	let nameSpaces: AuthorizedNameSpaces?
	let dataElements: AuthorizedDataElements?
	
	enum Keys: String {
		case nameSpaces
		case dataElements
	}
}

extension KeyAuthorizations: CBORDecodable {
	init?(cbor: CBOR) {
		guard case let .map(v) = cbor else { return nil }
		var ans: AuthorizedNameSpaces? = nil
		if case let .array(ar) = v[Keys.nameSpaces] {
			ans = ar.compactMap { if case let .utf8String(s) = $0 { return s} else { return nil} }
			if ans?.count == 0 { ans = nil }
		}
		nameSpaces = ans
		var de = [NameSpace: DataElementsArray]()
		if case let .map(mde) = v[Keys.dataElements] {
			for (k,v) in mde  {
				guard case let .utf8String(ns) = k, case let .array(cdea) = v else { continue }
				let dea = cdea.compactMap { if case let .utf8String(s) = $0 { return s} else { return nil} }
				guard dea.count > 0 else { continue }
				de[ns] = dea
			}
		}
		if de.count > 0 { dataElements = de } else { dataElements = nil }
	}
}

extension KeyAuthorizations: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var m = [CBOR: CBOR]()
		if let nameSpaces {
			m[.utf8String(Keys.nameSpaces.rawValue)] = .array(nameSpaces.map { .utf8String($0) })
		}
		if let dataElements {
			var d = [CBOR: CBOR]()
			for (k,v) in dataElements { d[.utf8String(k)] = .array(v.map { .utf8String($0) }) }
			m[.utf8String(Keys.dataElements.rawValue)] = .map(d)
		}
		return .map(m)
	}
}
