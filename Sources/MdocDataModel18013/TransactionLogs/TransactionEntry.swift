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

/// A single entry in the transaction log, as a typed model.
///
/// Every kind of transaction — a presentation, an issuance, a deletion, and so on — is its own
/// case, so you can tell them apart with a `switch` and read their fields type-safely. The model
/// follows the EUDI Wallet Technical Specification 10 (TS10): the shared fields below come from
/// §3.1, and each case maps to a TS10 transaction class (its §3.x reference is noted on it).
public enum TransactionEntry: Codable, Equatable, Sendable {
    /// A presentation transaction (TS10 §3.2).
    ///
    /// Records which claims were involved (via ``ClaimInfo``), never their values.
    case presentation(Presentation)

    /// A credential (PID or attestation) issuance transaction (TS10 §3.5).
    case credentialIssuance(CredentialIssuance)

    /// A credential (PID or attestation) re-issuance transaction.
    ///
    /// Same shape as ``credentialIssuance(_:)``; differs only by transaction type (TS10 §3.5).
    case credentialReissuance(CredentialReissuance)

    /// A credential (PID or attestation) deletion by the user (TS10 §3.6).
    case credentialDeletion(CredentialDeletion)

    /// A signature or seal creation transaction (TS10 §3.12).
    case signingSealing(SigningSealing)

    /// A data deletion request sent to a relying party (TS10 §3.13).
    case dataDeletionRequest(DataDeletionRequest)

    /// A suspicious transaction report sent to a data protection authority (TS10 §3.14).
    case dpaReport(DPAReport)

    /// A certificate or key pair issuance for signing/sealing (TS10 §3.10).
    case certificateIssuance(CertificateIssuance)

    /// Certificate or key pair deletion (TS10 §3.11).
    case certificateDeletion(CertificateDeletion)

    /// Wallet-to-Wallet presentation transaction (TS10 §3.4).
    case w2wPresentation(W2WPresentation)

    /// Wallet-to-Wallet presentation request transaction (TS10 §3.3).
    case w2wPresentationRequest(W2WPresentationRequest)

    /// Pseudonym generation transaction (TS10 §3.7).
    case pseudonymGeneration(PseudonymGeneration)

    /// Pseudonym deletion transaction (TS10 §3.8).
    case pseudonymDeletion(PseudonymDeletion)

    /// A pseudonym presentation (pseudonymous authentication) transaction (TS10 §3.9).
    case pseudonymousAuthentication(PseudonymousAuthentication)

    /// Any other transaction, e.g. backup or migration export (TS10 §3.15).
    case otherTransaction(OtherTransaction)

    /// Unique identifier of the transaction (TS10 §3.1 `transactionIdentifier`).
    public var transactionIdentifier: String {
        switch self {
        case .presentation(let value): return value.transactionIdentifier
        case .credentialIssuance(let value): return value.transactionIdentifier
        case .credentialReissuance(let value): return value.transactionIdentifier
        case .credentialDeletion(let value): return value.transactionIdentifier
        case .signingSealing(let value): return value.transactionIdentifier
        case .dataDeletionRequest(let value): return value.transactionIdentifier
        case .dpaReport(let value): return value.transactionIdentifier
        case .certificateIssuance(let value): return value.transactionIdentifier
        case .certificateDeletion(let value): return value.transactionIdentifier
        case .w2wPresentation(let value): return value.transactionIdentifier
        case .w2wPresentationRequest(let value): return value.transactionIdentifier
        case .pseudonymGeneration(let value): return value.transactionIdentifier
        case .pseudonymDeletion(let value): return value.transactionIdentifier
        case .pseudonymousAuthentication(let value): return value.transactionIdentifier
        case .otherTransaction(let value): return value.transactionIdentifier
        }
    }

    /// Date and time of the transaction (TS10 §3.1 `time`; serialized as ISO 8601).
    public var time: Date {
        switch self {
        case .presentation(let value): return value.time
        case .credentialIssuance(let value): return value.time
        case .credentialReissuance(let value): return value.time
        case .credentialDeletion(let value): return value.time
        case .signingSealing(let value): return value.time
        case .dataDeletionRequest(let value): return value.time
        case .dpaReport(let value): return value.time
        case .certificateIssuance(let value): return value.time
        case .certificateDeletion(let value): return value.time
        case .w2wPresentation(let value): return value.time
        case .w2wPresentationRequest(let value): return value.time
        case .pseudonymGeneration(let value): return value.time
        case .pseudonymDeletion(let value): return value.time
        case .pseudonymousAuthentication(let value): return value.time
        case .otherTransaction(let value): return value.time
        }
    }

    /// The transaction result (TS10 §3.1 `transactionResult`).
    public var transactionResult: TransactionResult {
        switch self {
        case .presentation(let value): return value.transactionResult
        case .credentialIssuance(let value): return value.transactionResult
        case .credentialReissuance(let value): return value.transactionResult
        case .credentialDeletion(let value): return value.transactionResult
        case .signingSealing(let value): return value.transactionResult
        case .dataDeletionRequest(let value): return value.transactionResult
        case .dpaReport(let value): return value.transactionResult
        case .certificateIssuance(let value): return value.transactionResult
        case .certificateDeletion(let value): return value.transactionResult
        case .w2wPresentation(let value): return value.transactionResult
        case .w2wPresentationRequest(let value): return value.transactionResult
        case .pseudonymGeneration(let value): return value.transactionResult
        case .pseudonymDeletion(let value): return value.transactionResult
        case .pseudonymousAuthentication(let value): return value.transactionResult
        case .otherTransaction(let value): return value.transactionResult
        }
    }

    /// Why the transaction did not complete, if known (TS10 §3.1 `reasonOfNoncompletion`).
    public var reasonOfNoncompletion: String? {
        switch self {
        case .presentation(let value): return value.reasonOfNoncompletion
        case .credentialIssuance(let value): return value.reasonOfNoncompletion
        case .credentialReissuance(let value): return value.reasonOfNoncompletion
        case .credentialDeletion(let value): return value.reasonOfNoncompletion
        case .signingSealing(let value): return value.reasonOfNoncompletion
        case .dataDeletionRequest(let value): return value.reasonOfNoncompletion
        case .dpaReport(let value): return value.reasonOfNoncompletion
        case .certificateIssuance(let value): return value.reasonOfNoncompletion
        case .certificateDeletion(let value): return value.reasonOfNoncompletion
        case .w2wPresentation(let value): return value.reasonOfNoncompletion
        case .w2wPresentationRequest(let value): return value.reasonOfNoncompletion
        case .pseudonymGeneration(let value): return value.reasonOfNoncompletion
        case .pseudonymDeletion(let value): return value.reasonOfNoncompletion
        case .pseudonymousAuthentication(let value): return value.reasonOfNoncompletion
        case .otherTransaction(let value): return value.reasonOfNoncompletion
        }
    }

    /// The transaction type discriminator (TS10 §3.1 `transactionType`).
    public var transactionType: TransactionType {
        switch self {
        case .presentation: return .presentation
        case .credentialIssuance: return .credentialIssuance
        case .credentialReissuance: return .credentialReissuance
        case .credentialDeletion: return .credentialDeletion
        case .signingSealing: return .signingSealing
        case .dataDeletionRequest: return .dataDeletionRequest
        case .dpaReport: return .dpaReport
        case .certificateIssuance: return .certificateIssuance
        case .certificateDeletion: return .certificateDeletion
        case .w2wPresentation: return .w2wPresentation
        case .w2wPresentationRequest: return .w2wPresentationRequest
        case .pseudonymGeneration: return .pseudonymGeneration
        case .pseudonymDeletion: return .pseudonymDeletion
        case .pseudonymousAuthentication: return .pseudonymPresentation
        case .otherTransaction: return .otherTransaction
        }
    }

    private enum CodingKeys: String, CodingKey {
        case transactionType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TransactionType.self, forKey: .transactionType)
        switch type {
        case .presentation: self = .presentation(try Presentation(from: decoder))
        case .credentialIssuance: self = .credentialIssuance(try CredentialIssuance(from: decoder))
        case .credentialReissuance: self = .credentialReissuance(try CredentialReissuance(from: decoder))
        case .credentialDeletion: self = .credentialDeletion(try CredentialDeletion(from: decoder))
        case .signingSealing: self = .signingSealing(try SigningSealing(from: decoder))
        case .dataDeletionRequest: self = .dataDeletionRequest(try DataDeletionRequest(from: decoder))
        case .dpaReport: self = .dpaReport(try DPAReport(from: decoder))
        case .certificateIssuance: self = .certificateIssuance(try CertificateIssuance(from: decoder))
        case .certificateDeletion: self = .certificateDeletion(try CertificateDeletion(from: decoder))
        case .w2wPresentation: self = .w2wPresentation(try W2WPresentation(from: decoder))
        case .w2wPresentationRequest: self = .w2wPresentationRequest(try W2WPresentationRequest(from: decoder))
        case .pseudonymGeneration: self = .pseudonymGeneration(try PseudonymGeneration(from: decoder))
        case .pseudonymDeletion: self = .pseudonymDeletion(try PseudonymDeletion(from: decoder))
        case .pseudonymPresentation:
            self = .pseudonymousAuthentication(try PseudonymousAuthentication(from: decoder))
        case .otherTransaction: self = .otherTransaction(try OtherTransaction(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .presentation(let value): try value.encode(to: encoder)
        case .credentialIssuance(let value): try value.encode(to: encoder)
        case .credentialReissuance(let value): try value.encode(to: encoder)
        case .credentialDeletion(let value): try value.encode(to: encoder)
        case .signingSealing(let value): try value.encode(to: encoder)
        case .dataDeletionRequest(let value): try value.encode(to: encoder)
        case .dpaReport(let value): try value.encode(to: encoder)
        case .certificateIssuance(let value): try value.encode(to: encoder)
        case .certificateDeletion(let value): try value.encode(to: encoder)
        case .w2wPresentation(let value): try value.encode(to: encoder)
        case .w2wPresentationRequest(let value): try value.encode(to: encoder)
        case .pseudonymGeneration(let value): try value.encode(to: encoder)
        case .pseudonymDeletion(let value): try value.encode(to: encoder)
        case .pseudonymousAuthentication(let value): try value.encode(to: encoder)
        case .otherTransaction(let value): try value.encode(to: encoder)
        }
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transactionType, forKey: .transactionType)
    }

    /// A presentation transaction (TS10 §3.2).
    public struct Presentation: Codable, Equatable, Sendable {
        public static let interactingPartyTypeDefault = "ServiceProvider"

        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            listOfClaimsRequested: [ClaimInfo],
            listOfClaimsPresented: [ClaimInfo],
            interactingPartyType: String = Presentation.interactingPartyTypeDefault,
            interactingPartyName: MultiLangString? = nil,
            interactingPartyIdentifier: QualifiedIdentifier? = nil,
            interactingPartyContact: [String]? = nil,
            isIntermediary: Bool? = nil,
            intermediaryIdentifier: QualifiedIdentifier? = nil,
            intermediaryName: MultiLangString? = nil,
            intermediaryContact: [String]? = nil,
            registrarURL: String? = nil,
            purpose: [MultiLangString]? = nil,
            privacyPolicy: [Policy]? = nil,
            dpaName: MultiLangString? = nil,
            dpaCountry: MultiLangString? = nil,
            dpaContact: [String]? = nil
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.listOfClaimsRequested = listOfClaimsRequested
            self.listOfClaimsPresented = listOfClaimsPresented
            self.interactingPartyType = interactingPartyType
            self.interactingPartyName = interactingPartyName
            self.interactingPartyIdentifier = interactingPartyIdentifier
            self.interactingPartyContact = interactingPartyContact
            self.isIntermediary = isIntermediary
            self.intermediaryIdentifier = intermediaryIdentifier
            self.intermediaryName = intermediaryName
            self.intermediaryContact = intermediaryContact
            self.registrarURL = registrarURL
            self.purpose = purpose
            self.privacyPolicy = privacyPolicy
            self.dpaName = dpaName
            self.dpaCountry = dpaCountry
            self.dpaContact = dpaContact
        }

        public let transactionIdentifier: String
        public let time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let listOfClaimsRequested: [ClaimInfo]
        public let listOfClaimsPresented: [ClaimInfo]
        public let interactingPartyType: String
        public let interactingPartyName: MultiLangString?
        public let interactingPartyIdentifier: QualifiedIdentifier?
        public let interactingPartyContact: [String]?
        public let isIntermediary: Bool?
        public let intermediaryIdentifier: QualifiedIdentifier?
        public let intermediaryName: MultiLangString?
        public let intermediaryContact: [String]?
        public let registrarURL: String?
        public let purpose: [MultiLangString]?
        public let privacyPolicy: [Policy]?
        public let dpaName: MultiLangString?
        public let dpaCountry: MultiLangString?
        public let dpaContact: [String]?

        private enum CodingKeys: String, CodingKey {
            case transactionIdentifier, time, transactionResult, reasonOfNoncompletion
            case listOfClaimsRequested, listOfClaimsPresented
            case interactingPartyType, interactingPartyName, interactingPartyIdentifier, interactingPartyContact
            case isIntermediary, intermediaryIdentifier, intermediaryName, intermediaryContact
            case registrarURL, purpose, privacyPolicy, dpaName, dpaCountry, dpaContact
        }

        // Swift's Codable synthesis doesn't use decodeIfPresent for Optional property-wrapped
        // fields, so isIntermediary and privacyPolicy are decoded manually here.
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            transactionIdentifier = try container.decode(String.self, forKey: .transactionIdentifier)
            time = try container.decode(ISO8601Coded.self, forKey: .time).wrappedValue
            transactionResult = try container.decode(TransactionResult.self, forKey: .transactionResult)
            reasonOfNoncompletion = try container.decodeIfPresent(String.self, forKey: .reasonOfNoncompletion)
            listOfClaimsRequested = try container.decode([ClaimInfo].self, forKey: .listOfClaimsRequested)
            listOfClaimsPresented = try container.decode([ClaimInfo].self, forKey: .listOfClaimsPresented)
            interactingPartyType = try container.decode(String.self, forKey: .interactingPartyType)
            interactingPartyName = try container.decodeIfPresent(MultiLangString.self, forKey: .interactingPartyName)
            interactingPartyIdentifier = try container.decodeIfPresent(QualifiedIdentifier.self, forKey: .interactingPartyIdentifier)
            interactingPartyContact = try container.decodeIfPresent([String].self, forKey: .interactingPartyContact)
            isIntermediary = try container.decodeIfPresent(LenientBoolCoded.self, forKey: .isIntermediary)?.wrappedValue
            intermediaryIdentifier = try container.decodeIfPresent(QualifiedIdentifier.self, forKey: .intermediaryIdentifier)
            intermediaryName = try container.decodeIfPresent(MultiLangString.self, forKey: .intermediaryName)
            intermediaryContact = try container.decodeIfPresent([String].self, forKey: .intermediaryContact)
            registrarURL = try container.decodeIfPresent(String.self, forKey: .registrarURL)
            purpose = try container.decodeIfPresent([MultiLangString].self, forKey: .purpose)
            privacyPolicy = try container.decodeIfPresent(OneOrManyCoded<Policy>.self, forKey: .privacyPolicy)?.wrappedValue
            dpaName = try container.decodeIfPresent(MultiLangString.self, forKey: .dpaName)
            dpaCountry = try container.decodeIfPresent(MultiLangString.self, forKey: .dpaCountry)
            dpaContact = try container.decodeIfPresent([String].self, forKey: .dpaContact)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(transactionIdentifier, forKey: .transactionIdentifier)
            try container.encode(ISO8601Coded(wrappedValue: time), forKey: .time)
            try container.encode(transactionResult, forKey: .transactionResult)
            try container.encodeIfPresent(reasonOfNoncompletion, forKey: .reasonOfNoncompletion)
            try container.encode(listOfClaimsRequested, forKey: .listOfClaimsRequested)
            try container.encode(listOfClaimsPresented, forKey: .listOfClaimsPresented)
            try container.encode(interactingPartyType, forKey: .interactingPartyType)
            try container.encodeIfPresent(interactingPartyName, forKey: .interactingPartyName)
            try container.encodeIfPresent(interactingPartyIdentifier, forKey: .interactingPartyIdentifier)
            try container.encodeIfPresent(interactingPartyContact, forKey: .interactingPartyContact)
            try container.encodeIfPresent(isIntermediary, forKey: .isIntermediary)
            try container.encodeIfPresent(intermediaryIdentifier, forKey: .intermediaryIdentifier)
            try container.encodeIfPresent(intermediaryName, forKey: .intermediaryName)
            try container.encodeIfPresent(intermediaryContact, forKey: .intermediaryContact)
            try container.encodeIfPresent(registrarURL, forKey: .registrarURL)
            try container.encodeIfPresent(purpose, forKey: .purpose)
            try container.encodeIfPresent(privacyPolicy, forKey: .privacyPolicy)
            try container.encodeIfPresent(dpaName, forKey: .dpaName)
            try container.encodeIfPresent(dpaCountry, forKey: .dpaCountry)
            try container.encodeIfPresent(dpaContact, forKey: .dpaContact)
        }
    }

    /// Shared payload for credential issuance and re-issuance (TS10 §3.5).
    ///
    /// Used by both ``CredentialIssuance`` and ``CredentialReissuance``. Its fields are flattened
    /// alongside the shared fields on the wire, not nested under a `details` key.
    public struct CredentialIssuanceDetails: Codable, Equatable, Sendable {
        public init(
            credentialNumberRequested: Int,
            credentialNumberIssued: Int,
            credentialIdentifier: [String],
            isUserTriggered: Bool? = nil,
            interactingPartyName: MultiLangString? = nil,
            interactingPartyIdentifier: QualifiedIdentifier? = nil,
            interactingPartyType: String? = nil,
            interactingPartyContact: [String]? = nil
        ) {
            self.credentialNumberRequested = credentialNumberRequested
            self.credentialNumberIssued = credentialNumberIssued
            self.credentialIdentifier = credentialIdentifier
            self.isUserTriggered = isUserTriggered
            self.interactingPartyName = interactingPartyName
            self.interactingPartyIdentifier = interactingPartyIdentifier
            self.interactingPartyType = interactingPartyType
            self.interactingPartyContact = interactingPartyContact
        }

        public let credentialNumberRequested: Int
        public let credentialNumberIssued: Int
        public let credentialIdentifier: [String]
        public let isUserTriggered: Bool?
        public let interactingPartyName: MultiLangString?
        public let interactingPartyIdentifier: QualifiedIdentifier?
        public let interactingPartyType: String?
        public let interactingPartyContact: [String]?
    }

    /// A credential (PID or attestation) issuance transaction (TS10 §3.5).
    public struct CredentialIssuance: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            details: CredentialIssuanceDetails
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.details = details
        }

        public let transactionIdentifier: String
        public let time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let details: CredentialIssuanceDetails

        private enum CodingKeys: String, CodingKey {
            case transactionIdentifier, time, transactionResult, reasonOfNoncompletion
            case credentialNumberRequested, credentialNumberIssued, credentialIdentifier, isUserTriggered
            case interactingPartyName, interactingPartyIdentifier, interactingPartyType, interactingPartyContact
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            transactionIdentifier = try container.decode(String.self, forKey: .transactionIdentifier)
            time = try container.decode(ISO8601Coded.self, forKey: .time).wrappedValue
            transactionResult = try container.decode(TransactionResult.self, forKey: .transactionResult)
            reasonOfNoncompletion = try container.decodeIfPresent(String.self, forKey: .reasonOfNoncompletion)
            details = CredentialIssuanceDetails(
                credentialNumberRequested: try container.decode(Int.self, forKey: .credentialNumberRequested),
                credentialNumberIssued: try container.decode(Int.self, forKey: .credentialNumberIssued),
                credentialIdentifier: try container.decode([String].self, forKey: .credentialIdentifier),
                isUserTriggered: try container.decodeIfPresent(LenientBoolCoded.self, forKey: .isUserTriggered)?.wrappedValue,
                interactingPartyName: try container.decodeIfPresent(MultiLangString.self, forKey: .interactingPartyName),
                interactingPartyIdentifier: try container.decodeIfPresent(QualifiedIdentifier.self, forKey: .interactingPartyIdentifier),
                interactingPartyType: try container.decodeIfPresent(String.self, forKey: .interactingPartyType),
                interactingPartyContact: try container.decodeIfPresent([String].self, forKey: .interactingPartyContact)
            )
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(transactionIdentifier, forKey: .transactionIdentifier)
            try container.encode(ISO8601Coded(wrappedValue: time), forKey: .time)
            try container.encode(transactionResult, forKey: .transactionResult)
            try container.encodeIfPresent(reasonOfNoncompletion, forKey: .reasonOfNoncompletion)
            try container.encode(details.credentialNumberRequested, forKey: .credentialNumberRequested)
            try container.encode(details.credentialNumberIssued, forKey: .credentialNumberIssued)
            try container.encode(details.credentialIdentifier, forKey: .credentialIdentifier)
            try container.encodeIfPresent(details.isUserTriggered, forKey: .isUserTriggered)
            try container.encodeIfPresent(details.interactingPartyName, forKey: .interactingPartyName)
            try container.encodeIfPresent(details.interactingPartyIdentifier, forKey: .interactingPartyIdentifier)
            try container.encodeIfPresent(details.interactingPartyType, forKey: .interactingPartyType)
            try container.encodeIfPresent(details.interactingPartyContact, forKey: .interactingPartyContact)
        }
    }

    /// A credential (PID or attestation) re-issuance transaction.
    ///
    /// Same shape as ``CredentialIssuance``; differs only by transaction type (TS10 §3.5).
    public struct CredentialReissuance: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            details: CredentialIssuanceDetails
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.details = details
        }

        public let transactionIdentifier: String
        public let time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let details: CredentialIssuanceDetails

        private enum CodingKeys: String, CodingKey {
            case transactionIdentifier, time, transactionResult, reasonOfNoncompletion
            case credentialNumberRequested, credentialNumberIssued, credentialIdentifier, isUserTriggered
            case interactingPartyName, interactingPartyIdentifier, interactingPartyType, interactingPartyContact
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            transactionIdentifier = try container.decode(String.self, forKey: .transactionIdentifier)
            time = try container.decode(ISO8601Coded.self, forKey: .time).wrappedValue
            transactionResult = try container.decode(TransactionResult.self, forKey: .transactionResult)
            reasonOfNoncompletion = try container.decodeIfPresent(String.self, forKey: .reasonOfNoncompletion)
            details = CredentialIssuanceDetails(
                credentialNumberRequested: try container.decode(Int.self, forKey: .credentialNumberRequested),
                credentialNumberIssued: try container.decode(Int.self, forKey: .credentialNumberIssued),
                credentialIdentifier: try container.decode([String].self, forKey: .credentialIdentifier),
                isUserTriggered: try container.decodeIfPresent(LenientBoolCoded.self, forKey: .isUserTriggered)?.wrappedValue,
                interactingPartyName: try container.decodeIfPresent(MultiLangString.self, forKey: .interactingPartyName),
                interactingPartyIdentifier: try container.decodeIfPresent(QualifiedIdentifier.self, forKey: .interactingPartyIdentifier),
                interactingPartyType: try container.decodeIfPresent(String.self, forKey: .interactingPartyType),
                interactingPartyContact: try container.decodeIfPresent([String].self, forKey: .interactingPartyContact)
            )
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(transactionIdentifier, forKey: .transactionIdentifier)
            try container.encode(ISO8601Coded(wrappedValue: time), forKey: .time)
            try container.encode(transactionResult, forKey: .transactionResult)
            try container.encodeIfPresent(reasonOfNoncompletion, forKey: .reasonOfNoncompletion)
            try container.encode(details.credentialNumberRequested, forKey: .credentialNumberRequested)
            try container.encode(details.credentialNumberIssued, forKey: .credentialNumberIssued)
            try container.encode(details.credentialIdentifier, forKey: .credentialIdentifier)
            try container.encodeIfPresent(details.isUserTriggered, forKey: .isUserTriggered)
            try container.encodeIfPresent(details.interactingPartyName, forKey: .interactingPartyName)
            try container.encodeIfPresent(details.interactingPartyIdentifier, forKey: .interactingPartyIdentifier)
            try container.encodeIfPresent(details.interactingPartyType, forKey: .interactingPartyType)
            try container.encodeIfPresent(details.interactingPartyContact, forKey: .interactingPartyContact)
        }
    }

    /// A credential (PID or attestation) deletion by the user (TS10 §3.6).
    public struct CredentialDeletion: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            credentialIdentifier: String,
            credentialIssuerIdentifier: QualifiedIdentifier? = nil,
            credentialIssuerName: MultiLangString? = nil
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.credentialIdentifier = credentialIdentifier
            self.credentialIssuerIdentifier = credentialIssuerIdentifier
            self.credentialIssuerName = credentialIssuerName
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let credentialIdentifier: String
        public let credentialIssuerIdentifier: QualifiedIdentifier?
        public let credentialIssuerName: MultiLangString?
    }

    /// A signature or seal creation transaction (TS10 §3.12).
    public struct SigningSealing: Codable, Equatable, Sendable {
        public static let interactingPartyTypeDefault = "ESigESealCreationProvider"

        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            interactingPartyType: String = SigningSealing.interactingPartyTypeDefault,
            signingTransactionIdentifier: String? = nil,
            certificateIdentifier: String? = nil,
            dtbsr: String? = nil,
            fileIdentifier: String? = nil,
            fileName: String? = nil,
            fileSize: String? = nil,
            interactingPartyName: MultiLangString? = nil,
            interactingPartyIdentifier: QualifiedIdentifier? = nil,
            interactingPartyContact: [String]? = nil
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.interactingPartyType = interactingPartyType
            self.signingTransactionIdentifier = signingTransactionIdentifier
            self.certificateIdentifier = certificateIdentifier
            self.dtbsr = dtbsr
            self.fileIdentifier = fileIdentifier
            self.fileName = fileName
            self.fileSize = fileSize
            self.interactingPartyName = interactingPartyName
            self.interactingPartyIdentifier = interactingPartyIdentifier
            self.interactingPartyContact = interactingPartyContact
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let interactingPartyType: String
        public let signingTransactionIdentifier: String?
        public let certificateIdentifier: String?
        public let dtbsr: String?
        public let fileIdentifier: String?
        public let fileName: String?
        public let fileSize: String?
        public let interactingPartyName: MultiLangString?
        public let interactingPartyIdentifier: QualifiedIdentifier?
        public let interactingPartyContact: [String]?
    }

    /// A data deletion request sent to a relying party (TS10 §3.13).
    public struct DataDeletionRequest: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            listOfClaims: [ClaimInfo],
            interactingPartyIdentifier: QualifiedIdentifier? = nil,
            interactingPartyName: MultiLangString? = nil
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.listOfClaims = listOfClaims
            self.interactingPartyIdentifier = interactingPartyIdentifier
            self.interactingPartyName = interactingPartyName
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let listOfClaims: [ClaimInfo]
        public let interactingPartyIdentifier: QualifiedIdentifier?
        public let interactingPartyName: MultiLangString?
    }

    /// A suspicious transaction report sent to a data protection authority (TS10 §3.14).
    public struct DPAReport: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            dpaName: MultiLangString? = nil,
            dpaCountry: MultiLangString? = nil
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.dpaName = dpaName
            self.dpaCountry = dpaCountry
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let dpaName: MultiLangString?
        public let dpaCountry: MultiLangString?
    }

    /// A certificate or key pair issuance for signing/sealing (TS10 §3.10).
    public struct CertificateIssuance: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            interactingPartyType: String? = nil,
            certificateIdentifier: String? = nil,
            interactingPartyName: MultiLangString? = nil,
            interactingPartyIdentifier: QualifiedIdentifier? = nil,
            interactingPartyContact: [String]? = nil
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.interactingPartyType = interactingPartyType
            self.certificateIdentifier = certificateIdentifier
            self.interactingPartyName = interactingPartyName
            self.interactingPartyIdentifier = interactingPartyIdentifier
            self.interactingPartyContact = interactingPartyContact
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let interactingPartyType: String?
        public let certificateIdentifier: String?
        public let interactingPartyName: MultiLangString?
        public let interactingPartyIdentifier: QualifiedIdentifier?
        public let interactingPartyContact: [String]?
    }

    /// Certificate or key pair deletion (TS10 §3.11).
    public struct CertificateDeletion: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            certificateIdentifier: String,
            certificateIssuerIdentifier: QualifiedIdentifier? = nil,
            certificateIssuerName: MultiLangString? = nil
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.certificateIdentifier = certificateIdentifier
            self.certificateIssuerIdentifier = certificateIssuerIdentifier
            self.certificateIssuerName = certificateIssuerName
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let certificateIdentifier: String
        public let certificateIssuerIdentifier: QualifiedIdentifier?
        public let certificateIssuerName: MultiLangString?
    }

    /// Wallet-to-Wallet presentation transaction (TS10 §3.4).
    public struct W2WPresentation: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            listOfClaimsRequested: [ClaimInfo],
            listOfClaimsPresented: [ClaimInfo]
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.listOfClaimsRequested = listOfClaimsRequested
            self.listOfClaimsPresented = listOfClaimsPresented
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let listOfClaimsRequested: [ClaimInfo]
        public let listOfClaimsPresented: [ClaimInfo]
    }

    /// Wallet-to-Wallet presentation request transaction (TS10 §3.3).
    public struct W2WPresentationRequest: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            listOfClaimsRequested: [ClaimInfo],
            listOfClaimsPresented: [ClaimInfo]
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.listOfClaimsRequested = listOfClaimsRequested
            self.listOfClaimsPresented = listOfClaimsPresented
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let listOfClaimsRequested: [ClaimInfo]
        public let listOfClaimsPresented: [ClaimInfo]
    }

    /// Pseudonym generation transaction (TS10 §3.7).
    public struct PseudonymGeneration: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            pseudonym: Pseudonym
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.pseudonym = pseudonym
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let pseudonym: Pseudonym
    }

    /// Pseudonym deletion transaction (TS10 §3.8).
    public struct PseudonymDeletion: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            pseudonym: Pseudonym
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.pseudonym = pseudonym
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let pseudonym: Pseudonym
    }

    /// A pseudonym presentation (pseudonymous authentication) transaction (TS10 §3.9).
    public struct PseudonymousAuthentication: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            pseudonym: Pseudonym,
            interactingPartyIdentifier: QualifiedIdentifier? = nil,
            interactingPartyType: String? = nil,
            interactingPartyName: MultiLangString? = nil
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.pseudonym = pseudonym
            self.interactingPartyIdentifier = interactingPartyIdentifier
            self.interactingPartyType = interactingPartyType
            self.interactingPartyName = interactingPartyName
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let pseudonym: Pseudonym
        public let interactingPartyIdentifier: QualifiedIdentifier?
        public let interactingPartyType: String?
        public let interactingPartyName: MultiLangString?
    }

    /// Any other transaction, e.g. backup or migration export (TS10 §3.15).
    public struct OtherTransaction: Codable, Equatable, Sendable {
        public init(
            transactionIdentifier: String,
            time: Date,
            transactionResult: TransactionResult,
            reasonOfNoncompletion: String? = nil,
            description: [String]
        ) {
            self.transactionIdentifier = transactionIdentifier
            self.time = time
            self.transactionResult = transactionResult
            self.reasonOfNoncompletion = reasonOfNoncompletion
            self.description = description
        }

        public let transactionIdentifier: String
        @ISO8601Coded public var time: Date
        public let transactionResult: TransactionResult
        public let reasonOfNoncompletion: String?
        public let description: [String]
    }
}
