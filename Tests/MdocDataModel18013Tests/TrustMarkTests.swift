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
import Testing
@testable import MdocDataModel18013

struct TrustMarkTests {
	// Information is configured separately from the resource, using the supplied integration URLs.
	private let requiredJSON = """
	{"TrustMarkResourceURL":"https://gist.githubusercontent.com/sraptis-scy/025334375fe26177d9a7bcb60fd8a93f/raw/TrustMarkResource.json",
	 "ListOfCertifiedWalletsURL":"https://eidas.ec.europa.eu/efda/wallet/certified",
	 "WalletSolutionInfoPageURL":"https://eidas.ec.europa.eu/efda/wallet/certified?id=WALLET_SOLUTION_ID"}
	"""

	// Unmodified snapshot of the Core-team Gist, downloaded 2026-09-28.
	// Source: https://gist.githubusercontent.com/sraptis-scy/025334375fe26177d9a7bcb60fd8a93f/raw/TrustMarkResource.json
	private func resourceFixture() throws -> TrustMarkResource {
		let url = try #require(Bundle.module.url(forResource: "TrustMarkResource", withExtension: "json"))
		return try JSONDecoder().decode(TrustMarkResource.self, from: Data(contentsOf: url))
	}

	@Test func resourceDecodesActualCoreTeamFixture() throws {
		let resource = try resourceFixture()
		#expect(resource.image.url == "https://eidas.ec.europa.eu/efda/assets/img/header/eu-logo.svg")
		#expect(resource.image.name == "eudi-wallet-trustmark-logo.png")
		#expect(resource.text.name == "Trust Mark user information, used for rendering in the EUDI Wallet user interface.")
		#expect(resource.text.localisations == [
			"en": "Officially Certified And Trusted EUDI Wallet",
			"de": "Beispieltext-für-Benutzer",
			"fr": "TexteExemple-pour-Utilisateurs"
		])
		#expect(try JSONDecoder().decode(TrustMarkResource.self, from: JSONEncoder().encode(resource)) == resource)
		let info = try JSONDecoder().decode(TrustMarkInformation.self, from: Data(requiredJSON.utf8))
		let mark = TrustMark(information: info, resource: resource)
		#expect(mark.imageURL?.absoluteString == resource.image.url)
		#expect(try JSONDecoder().decode(TrustMark.self, from: JSONEncoder().encode(mark)) == mark)
	}

	@Test func localizationsMatchActualCoreTeamFixture() throws {
		let resource = try resourceFixture()
		#expect(resource.text.localizedValue(for: "en") == "Officially Certified And Trusted EUDI Wallet")
		#expect(resource.text.localizedValue(for: "fr-FR") == "TexteExemple-pour-Utilisateurs")
		#expect(resource.text.localizedValue(for: "de-DE") == "Beispieltext-für-Benutzer")
	}
}
