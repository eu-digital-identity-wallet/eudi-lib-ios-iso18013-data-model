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

import Foundation
import SwiftCBOR
import OrderedCollections

/// Data item signed by issuer
public struct IssuerSignedItem {
    /// Digest ID for issuer data authentication
	public let digestID: UInt64
    /// Random value for issuer data authentication
    let random: [UInt8]
    /// Data element identifier
	public let elementIdentifier: DataElementIdentifier
    /// Data element value
	public let elementValue: DataElementValue
    /// Raw CBOR data
	public var rawData: [UInt8]?
    
    enum Keys: String {
       case digestID
       case random
       case elementIdentifier
       case elementValue
     }
}

extension CBOR: CustomStringConvertible {
	public var description: String {
        switch self {
        case .utf8String(let str): return str
		case .tagged(let tag, .utf8String(let str)): 
					if tag.rawValue == 1004 || tag == .standardDateTimeString { return str.usPosixDate() }
					return str
        case .unsignedInt(let i): return String(i)
        case .boolean(let b): return String(b)
		case .simple(let n): return String(n)
        default: return ""
        }
    }
}

extension CBOR: CustomDebugStringConvertible {
	public var debugDescription: String {
				switch self {
				case .utf8String(let str): return "'\(str)'"
		case .byteString(let bs): return "ByteString \(bs.count)"
		case .tagged(let tag, .utf8String(let str)): return "tag \(tag.rawValue) '\(str)'"
		case .tagged(let tag, .byteString(let bs)): return "tag \(tag.rawValue) 'ByteString \(bs.count)'"
				case .unsignedInt(let i): return String(i)
				case .boolean(let b): return String(b)
		case .array(let a): return "[\(a.reduce("", { $0 + ($0.count > 0 ? "," : "") + " \($1.debugDescription)" }))]"
		case .map(let m): return "{\(m.reduce("", { $0 + ($0.count > 0 ? "," : "") + " \($1.key.debugDescription): \($1.value.debugDescription)" }))}"
		case .null: return "Null"
		case .simple(let n): return String(n)
				default: return "Other"
				}
		}
}

extension CBOR {
	public var mdocDataType: MdocDataType? {
		switch self {
		case .utf8String(_), .null: return .string
		case .byteString(_): return .bytes
		case .map(_): return .dictionary
		case .array(_): return .array
		case .boolean(_): return .boolean
		case .tagged(.standardDateTimeString, _): return .date
		case .tagged(Tag(rawValue: 1004), _): return .date
		case .tagged(_, .utf8String(_)): return .string
		case .simple(_), .unsignedInt(_): return .integer
		case .float(_), .double(_): return .double
		default:
			return nil
		}
	}
}

extension IssuerSignedItem: CustomStringConvertible {
	public var description: String { elementValue.description }
}

extension IssuerSignedItem: CustomDebugStringConvertible {
	public var debugDescription: String { elementValue.debugDescription }
}

extension IssuerSignedItem {
	public var mdocDataType: MdocDataType? { elementValue.mdocDataType }
}

extension IssuerSignedItem: CBORDecodable {
	public init?(data: [UInt8]) {
        guard let cbor = try? CBOR.decode(data) else { return nil }
        self.init(cbor: cbor)
        rawData = data
    }

	public init?(cbor: CBOR) {
		guard case .map(let cd) = cbor else { return nil }
        guard case .unsignedInt(let did) = cd[Keys.digestID] else { return nil }
        digestID = did
        guard case .byteString(let r) = cd[Keys.random] else { return nil }
        random = r
        guard case .utf8String(let ei) = cd[Keys.elementIdentifier] else { return nil }
        elementIdentifier = ei
        guard let ev = cd[Keys.elementValue] else { return nil }
        elementValue = ev
    }
}

extension IssuerSignedItem: CBOREncodable {
    /// NOT tagged
	public func encode(options: CBOROptions) -> [UInt8] {
        if let rawData { return rawData }
        // it is not recommended to encode again, the digest may change
        return toCBOR(options: CBOROptions()).encode()
    }
    
	public func toCBOR(options: CBOROptions) -> CBOR {
        var cbor = OrderedDictionary<CBOR, CBOR>()
        cbor[.utf8String(Keys.digestID.rawValue)] = .unsignedInt(digestID)
        cbor[.utf8String(Keys.random.rawValue)] = .byteString(random)
        cbor[.utf8String(Keys.elementIdentifier.rawValue)] = .utf8String(elementIdentifier)
        cbor[.utf8String(Keys.elementValue.rawValue)] = elementValue
        return .map(cbor)
    }
}
