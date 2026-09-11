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

/// The kind of a transaction.
///
/// Each ``TransactionEntry`` case maps to one value. `credentialIssuance` and `credentialReissuance`
/// are separate values but share the same data. Each name matches the TS10 string used on the wire.
public enum TransactionType: String, Codable, Equatable, Sendable {
    case presentation = "Presentation"
    case pseudonymPresentation = "PseudonymPresentation"
    case w2wPresentation = "W2WPresentation"
    case w2wPresentationRequest = "W2WPresentationRequest"
    case credentialIssuance = "CredentialIssuance"
    case credentialReissuance = "CredentialReissuance"
    case credentialDeletion = "CredentialDeletion"
    case pseudonymGeneration = "PseudonymGeneration"
    case pseudonymDeletion = "PseudonymDeletion"
    case certificateIssuance = "CertificateIssuance"
    case certificateDeletion = "CertificateDeletion"
    case signingSealing = "SigningSealing"
    case dataDeletionRequest = "DataDeletionRequest"
    case dpaReport = "DPAReport"
    case otherTransaction = "OtherTransaction"
}
