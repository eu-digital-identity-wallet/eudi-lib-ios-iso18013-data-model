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
    case missingField(String, String)
    case connectionMethodHttpInvalidCbor(String)

    public var errorDescription: String? {
        switch self {
        case .cborDecodingError:
            return NSLocalizedString("Failed to decode CBOR data", comment: "Error message for CBOR decoding failure")
        case .invalidCbor(let component):
            return NSLocalizedString("Invalid CBOR format in \(component)", comment: "Error message for invalid CBOR format")
        case .missingField(let component, let field):
            return NSLocalizedString("Missing field in \(component): \(field)", comment: "Error message for missing field")
        case .connectionMethodHttpInvalidCbor(let reason):
            return NSLocalizedString("Invalid CBOR format in connection method HTTP: \(reason)", comment: "Error message for invalid CBOR format in connection method HTTP")
        }
    }
}