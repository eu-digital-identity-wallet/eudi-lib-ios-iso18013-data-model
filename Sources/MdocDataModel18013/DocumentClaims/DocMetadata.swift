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

public struct DocMetadata: Sendable, Codable {
	/// the credential issuer identifier (issuer URL)
	public let credentialIssuerIdentifier: String
	/// the document configuration identifier
	public let configurationIdentifier: String
	/// the document type
	public let docType: String?
	/// get display name of the document for the given culture
	public func getDisplayName(_ uiCulture: String?) -> String? { display?.getName(uiCulture) }
	/// display properties for the document
	public let display: [DisplayMetadata]?
	/// display properties of the issuer that issued the document
	public let issuerDisplay: [DisplayMetadata]?
	/// get display name of the issuer for the given culture
	public func getIssuerDisplayName(_ uiCulture: String?) -> String? { issuerDisplay?.getName(uiCulture) }
	/// claims (for mso-mdoc and sd-jwt documents)
	public let claims: [DocClaimMetadata]?

	public init(credentialIssuerIdentifier: String, configurationIdentifier: String, docType: String?, display: [DisplayMetadata]?, issuerDisplay: [DisplayMetadata]?, claims: [DocClaimMetadata]? = nil) {
		self.credentialIssuerIdentifier = credentialIssuerIdentifier
		self.configurationIdentifier = configurationIdentifier
		self.docType = docType
		self.display = display
		self.issuerDisplay = issuerDisplay
		self.claims = claims
	}

	public init?(from data: Data?) {
		guard let data else { return nil }
		do { self = try JSONDecoder().decode(DocMetadata.self, from: data) }
		catch { return nil }
	}

	public func toData() -> Data? {
		do { return try JSONEncoder().encode(self) }
		catch { return nil }
	}
}

