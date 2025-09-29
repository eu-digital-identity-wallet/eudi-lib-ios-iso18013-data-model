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
    case invalidCbor(String)
    case validityInfoMissingField(String)
    case issuerSignedItemMissingField(String)
    case issuerSignedMissingField(String)
    case msoMissingField(String)
    case coseKeyMissingField(String)
    case deviceRequestMissingField(String)
    case docRequestMissingField(String)
    case originInfoWebsiteMissingField(String)
    case connectionMethodHttpInvalidCbor(String)
    case deviceKeyInfoMissingField(String)
    case readerAuthMissingField(String)
    case itemsRequestMissingField(String)

    public var errorDescription: String? {
        switch self {
        case .cborDecodingError:
            return NSLocalizedString("Failed to decode CBOR data", comment: "Error message for CBOR decoding failure")
        case .invalidCbor(let component):
            return NSLocalizedString("Invalid CBOR format in \(component)", comment: "Error message for invalid CBOR format")
        case .validityInfoMissingField(let info):
            return NSLocalizedString("Missing field in validity info: \(info)", comment: "Error message for missing field in validity info")
        case .issuerSignedItemMissingField(let info):
            return NSLocalizedString("Missing field in issuer signed item: \(info)", comment: "Error message for missing field in issuer signed item")
        case .issuerSignedMissingField(let info):
            return NSLocalizedString("Missing field in issuer signed: \(info)", comment: "Error message for missing field in issuer signed")
        case .msoMissingField(let info):
            return NSLocalizedString("Missing field in mobile security object: \(info)", comment: "Error message for missing field in mobile security object")
        case .coseKeyMissingField(let info):
            return NSLocalizedString("Missing field in COSE key: \(info)", comment: "Error message for missing field in COSE key")
        case .deviceRequestMissingField(let info):
            return NSLocalizedString("Missing field in device request: \(info)", comment: "Error message for missing field in device request")
        case .docRequestMissingField(let info):
            return NSLocalizedString("Missing field in document request: \(info)", comment: "Error message for missing field in document request")
        case .originInfoWebsiteMissingField(let info):
            return NSLocalizedString("Missing field in origin info website: \(info)", comment: "Error message for missing field in origin info website")
        case .connectionMethodHttpInvalidCbor(let reason):
            return NSLocalizedString("Invalid CBOR format in connection method HTTP: \(reason)", comment: "Error message for invalid CBOR format in connection method HTTP")
        case .deviceKeyInfoMissingField(let info):
            return NSLocalizedString("Missing field in device key info: \(info)", comment: "Error message for missing field in device key info")
        case .readerAuthMissingField(let info):
            return NSLocalizedString("Missing field in reader authentication: \(info)", comment: "Error message for missing field in reader authentication")
        case .itemsRequestMissingField(let info):
            return NSLocalizedString("Missing field in items request: \(info)", comment: "Error message for missing field in items request")
        }
    }
}