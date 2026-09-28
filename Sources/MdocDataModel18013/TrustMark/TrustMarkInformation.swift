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

/// Trust Mark information delivered to a wallet provider after certification (EC TS01 v1.2).
public struct TrustMarkInformation: Codable, Equatable, Sendable {
	public let trustMarkResourceURL: String
	public let listOfCertifiedWalletsURL: String
	public let walletSolutionInfoPageURL: String
	/// Optional Base64-encoded QR code for the list of certified wallets.
	public let listOfCertifiedWalletsQRCode: String?
	/// Optional Base64-encoded QR code for this wallet's certification page.
	public let walletSolutionInfoPageQRCode: String?
	public let walletVerifierToolURL: String?

	public init(
		trustMarkResourceURL: String,
		listOfCertifiedWalletsURL: String,
		walletSolutionInfoPageURL: String,
		listOfCertifiedWalletsQRCode: String? = nil,
		walletSolutionInfoPageQRCode: String? = nil,
		walletVerifierToolURL: String? = nil
	) {
		self.trustMarkResourceURL = trustMarkResourceURL
		self.listOfCertifiedWalletsURL = listOfCertifiedWalletsURL
		self.walletSolutionInfoPageURL = walletSolutionInfoPageURL
		self.listOfCertifiedWalletsQRCode = listOfCertifiedWalletsQRCode
		self.walletSolutionInfoPageQRCode = walletSolutionInfoPageQRCode
		self.walletVerifierToolURL = walletVerifierToolURL
	}

	enum CodingKeys: String, CodingKey {
		case trustMarkResourceURL = "TrustMarkResourceURL"
		case listOfCertifiedWalletsURL = "ListOfCertifiedWalletsURL"
		case walletSolutionInfoPageURL = "WalletSolutionInfoPageURL"
		case listOfCertifiedWalletsQRCode = "ListOfCertifiedWalletsQRCode"
		case walletSolutionInfoPageQRCode = "WalletSolutionInfoPageQRCode"
		case walletVerifierToolURL = "WalletVerifierToolURL"
	}
}
