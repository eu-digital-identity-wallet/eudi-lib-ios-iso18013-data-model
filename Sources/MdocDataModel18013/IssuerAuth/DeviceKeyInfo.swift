//
//  KeyAuthorizations.swift

import Foundation
import SwiftCBOR

typealias AuthorizedNameSpaces = [NameSpace]
typealias DataElementsArray = [DataElementIdentifier]
typealias AuthorizedDataElements = [NameSpace: DataElementsArray]

/// mdoc authentication public key and information related to this key.
struct DeviceKeyInfo {
	let deviceKey: CoseKey
	let keyAuthorizations: KeyAuthorizations?
	let keyInfo: CBOR?
	
	enum Keys: String {
		case deviceKey
		case keyAuthorizations
		case keyInfo
	}
}

extension DeviceKeyInfo: CBORDecodable {
	init?(cbor: CBOR) {
		guard case let .map(v) = cbor else { return nil }
		guard let cdk = v[Keys.deviceKey], let dk = CoseKey(cbor: cdk) else { return nil }
		deviceKey = dk
		if let cka = v[Keys.keyAuthorizations], let ka = KeyAuthorizations(cbor: cka) { keyAuthorizations = ka } else { keyAuthorizations = nil }
		keyInfo = v[Keys.keyInfo]
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
