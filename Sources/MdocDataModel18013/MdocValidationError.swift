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

/// Enumeration of possible validation errors when validating an mdoc
public enum MdocValidationError: LocalizedError, Sendable {
    case cborDecodingError
    case validityInfoInvalidCbor
    case validityInfoMissingField(String)
    case issuerSignedItemInvalidCbor
    case issuerSignedItemMissingField(String)
    case issuerSignedInvalidCbor
    case issuerSignedMissingField(String)
    case valueDigestsInvalidCbor
    case issuerAuthInvalidCbor
    case msoInvalidCbor
    case msoMissingField(String)
    case coseKeyInvalidCbor
    case coseKeyMissingField(String)
    case deviceRequestInvalidCbor
    case deviceRequestMissingField(String)
    case docRequestInvalidCbor
    case docRequestMissingField(String)
    case originInfoWebsiteInvalidCbor
    case originInfoWebsiteMissingField(String)
    case documentInvalidCbor
    case connectionMethodHttpInvalidCbor(String)
    case errorsInvalidCbor
    case deviceEngagementInvalidCbor
    case deviceSignedInvalidCbor
    case documentErrorInvalidCbor
    case deviceRetrievalMethodInvalidCbor
    case serverRetrievalMethodInvalidCbor
    case drivingPrivilegeInvalidCbor
    case drivingPrivilegeCodeInvalidCbor
    case drivingPrivilegesInvalidCbor
    case deviceResponseInvalidCbor
    case deviceKeyInfoInvalidCbor
    case securityInvalidCbor
    case deviceAuthInvalidCbor
    case deviceKeyInfoMissingField(String)
    case readerAuthInvalidCbor
    case keyAuthorizationsInvalidCbor
    case readerAuthMissingField(String)
    case itemsRequestInvalidCbor
    case itemsRequestMissingField(String)
    case requestNameSpacesInvalidCbor
    case requestDataElementsInvalidCbor

    public var errorDescription: String? {
        switch self {
        case .cborDecodingError:
            return NSLocalizedString("Failed to decode CBOR data", comment: "Error message for CBOR decoding failure")
        case .issuerSignedItemInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in issuer signed item", comment: "Error message for invalid CBOR format in issuer signed item")
        case .issuerSignedItemMissingField (let info):
            return NSLocalizedString("Missing field in issuer signed item: \(info)", comment: "Error message for missing field in issuer signed item")
        case .validityInfoInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in validity info", comment: "Error message for invalid CBOR format in validity info")
        case .validityInfoMissingField (let info):
            return NSLocalizedString("Missing field in validity info: \(info)", comment: "Error message for missing field in validity info")
        case .issuerSignedInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in issuer signed", comment: "Error message for invalid CBOR format in issuer signed")
        case .issuerSignedMissingField(let info):
            return NSLocalizedString("Missing field in issuer signed: \(info)", comment: "Error message for missing field in issuer signed")
        case .valueDigestsInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in value digests", comment: "Error message for invalid CBOR format in value digests")
        case .issuerAuthInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in issuer auth", comment: "Error message for invalid CBOR format in issuer auth")
        case .msoInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in mobile security object", comment: "Error message for invalid CBOR format in mobile security object")
        case .msoMissingField(let info):
            return NSLocalizedString("Missing field in mobile security object: \(info)", comment: "Error message for missing field in mobile security object")
        case .coseKeyInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in COSE key", comment: "Error message for invalid CBOR format in COSE key")
        case .coseKeyMissingField(let info):
            return NSLocalizedString("Missing field in COSE key: \(info)", comment: "Error message for missing field in COSE key")
        case .deviceRequestInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in device request", comment: "Error message for invalid CBOR format in device request")
        case .deviceRequestMissingField(let info):
            return NSLocalizedString("Missing field in device request: \(info)", comment: "Error message for missing field in device request")
        case .docRequestInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in document request", comment: "Error message for invalid CBOR format in document request")
        case .docRequestMissingField(let info):
            return NSLocalizedString("Missing field in document request: \(info)", comment: "Error message for missing field in document request")
        case .originInfoWebsiteInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in origin info website", comment: "Error message for invalid CBOR format in origin info website")
        case .originInfoWebsiteMissingField(let info):
            return NSLocalizedString("Missing field in origin info website: \(info)", comment: "Error message for missing field in origin info website")
        case .documentInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in document", comment: "Error message for invalid CBOR format in document")
        case .connectionMethodHttpInvalidCbor(let reason):
            return NSLocalizedString("Invalid CBOR format in connection method HTTP: \(reason)", comment: "Error message for invalid CBOR format in connection method HTTP")
        case .errorsInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in errors", comment: "Error message for invalid CBOR format in errors")
        case .deviceSignedInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in device signed", comment: "Error message for invalid CBOR format in device signed")
        case .documentErrorInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in document error", comment: "Error message for invalid CBOR format in document error")
        case .deviceRetrievalMethodInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in device retrieval method", comment: "Error message for invalid CBOR format in device retrieval method")
        case .serverRetrievalMethodInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in server retrieval method", comment: "Error message for invalid CBOR format in server retrieval method")
        case .drivingPrivilegeInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in driving privilege", comment: "Error message for invalid CBOR format in driving privilege")
        case .drivingPrivilegesInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in driving privileges", comment: "Error message for invalid CBOR format in driving privileges")
        case .deviceResponseInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in device response", comment: "Error message for invalid CBOR format in device response")
        case .deviceKeyInfoInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in device key info", comment: "Error message for invalid CBOR format in device key info")
        case .deviceKeyInfoMissingField(let info):
            return NSLocalizedString("Missing field in device key info: \(info)", comment: "Error message for missing field in device key info")
        case .drivingPrivilegeCodeInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in driving privilege code", comment: "Error message for invalid CBOR format in driving privilege code")
        case .deviceEngagementInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in device engagement", comment: "Error message for invalid CBOR format in device engagement")
        case .securityInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in security", comment: "Error message for invalid CBOR format in security")
        case .deviceAuthInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in device authentication", comment: "Error message for invalid CBOR format in device authentication")
        case .readerAuthInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in reader authentication", comment: "Error message for invalid CBOR format in reader authentication")
        case .keyAuthorizationsInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in key authorizations", comment: "Error message for invalid CBOR format in key authorizations")
        case .readerAuthMissingField(let info):
            return NSLocalizedString("Missing field in reader authentication: \(info)", comment: "Error message for missing field in reader authentication")
        case .itemsRequestInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in items request", comment: "Error message for invalid CBOR format in items request")
        case .itemsRequestMissingField(let info):
            return NSLocalizedString("Missing field in items request: \(info)", comment: "Error message for missing field in items request")
        case .requestNameSpacesInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in request name spaces", comment: "Error message for invalid CBOR format in request name spaces")
        case .requestDataElementsInvalidCbor:
            return NSLocalizedString("Invalid CBOR format in request data elements", comment: "Error message for invalid CBOR format in request data elements")
        }
    }
}