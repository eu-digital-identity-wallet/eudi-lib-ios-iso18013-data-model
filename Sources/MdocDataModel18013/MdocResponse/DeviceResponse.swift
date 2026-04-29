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
import OrderedCollections

/// Device retrieval mdoc response. It is CBOR encoded
///
/// In mdoc reader initialize from CBOR data received from holder (data exchange)
/// In mdoc holder initialize from CBOR data received from server (registration)
///
/// ```swift
/// let dr = DeviceResponse(data: bytes)
/// ```
public struct DeviceResponse: Sendable {
	public let version: String
	public static let defaultVersion = version1
	public static let version1 = "1.0"
	public static let version2 = "1.1"
	/// An array of all returned documents
	public let documents: [Document]?
	/// An array of all returned ZK documents
	public let zkDocuments: [ZkDocument]?
	/// An array of all returned document errors
	public let documentErrors: [DocumentError]?
	public let status: UInt64

	enum Keys: String {
		case version
		case documents
		case zkDocuments
		case documentErrors
		case status
	}

	public init(version: String? = nil, documents: [Document]? = nil, zkDocuments: [ZkDocument]? = nil, documentErrors: [DocumentError]? = nil, status: UInt64? = nil) {
		self.version = version ?? (zkDocuments != nil ? Self.version2 : Self.defaultVersion)
		self.documents = documents
		self.zkDocuments = zkDocuments
		self.documentErrors = documentErrors
		self.status = status ?? 0
	}
}

extension DeviceResponse: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case .map(let cborMap) = cbor else { throw .invalidCbor("device response") }
		guard case .utf8String(let versionString) = cborMap[Keys.version] else { throw .missingField("DeviceResponse", Keys.version.rawValue) }
		try MdocVersion.validateDeviceVersion(versionString, component: "device response")
		version = versionString
		if case let .array(documentCbors) = cborMap[Keys.documents] {
			guard !documentCbors.isEmpty else { throw .invalidCbor("DeviceResponse.documents empty array") }
			let parsedDocuments = try documentCbors.map { documentCbor  throws(MdocValidationError) in try Document(cbor: documentCbor) }
			self.documents = parsedDocuments
		} else { documents = nil }
		if case let .array(zkDocumentCbors) = cborMap[Keys.zkDocuments] {
			guard !zkDocumentCbors.isEmpty else { throw .invalidCbor("DeviceResponse.zkDocuments empty array") }
			let parsedZkDocuments = try zkDocumentCbors.map { zkDocumentCbor throws(MdocValidationError) in try ZkDocument(cbor: zkDocumentCbor) }
			self.zkDocuments = parsedZkDocuments
		} else { zkDocuments = nil }
		if case let .array(documentErrorCbors) = cborMap[Keys.documentErrors] {
			guard !documentErrorCbors.isEmpty else { throw .invalidCbor("DeviceResponse.documentErrors empty array") }
			let parsedDocumentErrors = try documentErrorCbors.map { documentErrorCbor throws(MdocValidationError) in try DocumentError(cbor: documentErrorCbor) }
			self.documentErrors = parsedDocumentErrors
		}  else { documentErrors = nil }
		guard case .unsignedInt(let statusValue) = cborMap[Keys.status] else { throw .missingField("DeviceResponse", Keys.status.rawValue) }
		status = statusValue
	}
}

extension DeviceResponse: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = OrderedDictionary<CBOR, CBOR>()
		cbor[.utf8String(Keys.version.rawValue)] = .utf8String(version)
		if let documents { cbor[.utf8String(Keys.documents.rawValue)] = documents.toCBOR(options: options) }
		if let zkDocuments { cbor[.utf8String(Keys.zkDocuments.rawValue)] = .array(zkDocuments.map { $0.toCBOR(options: options) }) }
		if let documentErrors { cbor[.utf8String(Keys.documentErrors.rawValue)] = .array(documentErrors.map { $0.toCBOR(options: options) }) }
		cbor[.utf8String(Keys.status.rawValue)] = .unsignedInt(status)
		return .map(cbor)
	}
}

