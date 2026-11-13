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

import Testing
import Foundation
@testable import MdocDataModel18013

/// Matches the `{"TransactionLog": [...]}` root of the TS10 spec's non-normative example
/// (§4.1 Transaction Log Object Structure).
private struct TS10ExampleTransactionLogFile: Decodable {
    let transactionLog: [TransactionEntry]

    private enum CodingKeys: String, CodingKey {
        case transactionLog = "TransactionLog"
    }
}

struct TS10ExampleTests {
    @Test func decodeTransLogExampleJson() throws {
            let data = try #require(Data(name: "trans_log", ext: "json", from: Bundle.module))
            let file = try JSONDecoder().decode(TS10ExampleTransactionLogFile.self, from: data)
            #expect(file.transactionLog.count == 11)

            guard case .credentialIssuance(let issuance) = file.transactionLog[0] else {
                Issue.record("Expected a credentialIssuance entry")
                return
            }
            #expect(issuance.transactionIdentifier == "f354973e-88e2-47cc-a0e2-e70ae6716b7b")
            #expect(issuance.transactionResult == .completed)
            #expect(issuance.details.credentialNumberRequested == 2)
            #expect(issuance.details.credentialNumberIssued == 2)
            #expect(issuance.details.credentialIdentifier == ["eu.europa.ec.eudi.pid.1", "urn:eudi:pid:1"])
            #expect(issuance.details.isUserTriggered == true)
            #expect(issuance.details.interactingPartyName?.content == "Digital Credentials Issuer")

            guard case .credentialIssuance(let deferredIssuance) = file.transactionLog[1] else {
                Issue.record("Expected a credentialIssuance entry")
                return
            }
            #expect(deferredIssuance.transactionIdentifier == "deferred:_7BEDJeslLXf")
            // Some entries omit isUserTriggered entirely.
            #expect(deferredIssuance.details.isUserTriggered == nil)

            guard case .credentialDeletion(let deletion) = file.transactionLog[5] else {
                Issue.record("Expected a credentialDeletion entry")
                return
            }
            #expect(deletion.transactionIdentifier == "bb9feb2e-fb2f-47ba-a8a0-5287e3c35416")
            #expect(deletion.credentialIdentifier == "org.iso.23220.2.photoid.1")
            #expect(deletion.credentialIssuerName?.content == "Digital Credentials Issuer")

            guard case .presentation(let presentation) = file.transactionLog[6] else {
                Issue.record("Expected a presentation entry")
                return
            }
            #expect(presentation.transactionResult == .completed)
            #expect(presentation.interactingPartyType == "ServiceProvider")
            #expect(presentation.interactingPartyName?.content == "EUDI Remote Verifier")
            #expect(presentation.listOfClaimsRequested.count == 2)
            #expect(presentation.listOfClaimsPresented.count == 1)
            // mdoc claims are rendered as [namespace, dataElement] path arrays.
            #expect(presentation.listOfClaimsRequested.first?.credentialIdentifier == "eu.europa.ec.eudi.pid.1")
            #expect(presentation.listOfClaimsPresented.first?.claims.first == ClaimPath([.claim(name: "eu.europa.ec.eudi.pid.1"), .claim(name: "family_name")]))
            #expect(presentation.listOfClaimsPresented.first?.claims.count == 5)

            guard case .signingSealing(let signing) = file.transactionLog[8] else {
                Issue.record("Expected a signingSealing entry")
                return
            }
            #expect(signing.transactionIdentifier == "0ccc6d9d-612d-4255-a232-1fe52f74953a")
            #expect(signing.interactingPartyType == "ESigESealCreationProvider")
            #expect(signing.signingTransactionIdentifier == "b2892ab5-4ecc-4ce3-a560-ef4a31469f6c")
            #expect(signing.certificateIdentifier == "110487404804385887857364854113372412110212615551")
            #expect(signing.dtbsr == "8P5HbYEKfAVPSz0qUcct8UWArsuXt48NrC3tJanD75s=")
            #expect(signing.fileName == "dummy_1.pdf")
            #expect(signing.fileSize == "58399")

            guard case .presentation(let notCompleted) = file.transactionLog.last else {
                Issue.record("Expected a presentation entry")
                return
            }
            #expect(notCompleted.transactionIdentifier == "f7e57788-3d03-4f4e-9c58-2aeb4eaab913")
            #expect(notCompleted.transactionResult == .notCompleted)
            #expect(notCompleted.reasonOfNoncompletion == "Presentation stopped before completion")
            #expect(notCompleted.listOfClaimsRequested.count == 2)
            #expect(notCompleted.listOfClaimsPresented.isEmpty)
    }

    @Test func decodeTs10ExampleJson() throws {
        let data = try #require(Data(name: "ts10example", ext: "json", from: Bundle.module))
        let file = try #require(data.decodeJSON(type: TS10ExampleTransactionLogFile.self))
        #expect(file.transactionLog.count == 2)

        guard case .presentation(let first) = file.transactionLog[0] else {
            Issue.record("Expected a presentation entry")
            return
        }
        #expect(first.transactionIdentifier == "346354209358604")
        #expect(first.transactionResult == .completed)
        #expect(first.interactingPartyIdentifier == QualifiedIdentifier(type: "http://data.europa.eu/eudi/id/EUID", value: "PLKRS.0000123456"))
        // The example renders these MultiLangString-typed fields as bare strings.
        #expect(first.interactingPartyName?.content == "ABC Services")
        #expect(first.dpaName?.content == "Urząd Ochrony Danych Osobowych")
        #expect(first.dpaCountry?.content == "PL")
        // The example renders isIntermediary as the string "FALSE" rather than a boolean.
        #expect(first.isIntermediary == false)
        // The example renders privacyPolicy as a single object rather than an array.
        #expect(first.privacyPolicy?.first?.policyURI == "https://www.serviceprovider.com/policy/")
        #expect(first.purpose?.first?.lang == "pl-PL")
        #expect(first.interactingPartyContact == ["PL", "info@serviceprovider.com", "0048221234567", "https://www.serviceprovider.com/info/"])

        // The example renders each claim as a bare name rather than a full path array.
        let requestedClaims = try #require(first.listOfClaimsRequested.first)
        #expect(requestedClaims.credentialIdentifier == "urn:eudi:pid:de:1")
        #expect(requestedClaims.claims == [.claim("name"), .claim("address")])

        guard case .presentation(let second) = file.transactionLog[1] else {
            Issue.record("Expected a presentation entry")
            return
        }
        #expect(second.transactionResult == .notCompleted)
        #expect(second.reasonOfNoncompletion == "session interrupted")
        #expect(second.listOfClaimsPresented.isEmpty)
        #expect(second.purpose?.count == 2)
    }
}
