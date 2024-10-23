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

/// Elliptic curve identifiers  from the [IANA COSE registry](https://www.iana.org/assignments/cose/cose.xhtml).

/// This list is a superset of the iOS natively supported curves
public enum CoseEcCurve: UInt64, Sendable {
    /// The curve identifier for P-256
    case P256 = 1
    /// The curve identifier for P-384
    case P384 = 2
    /// The curve identifier for P-521
    case P521 = 3
    /// The curve identifier for brainpoolP256r1
    case BRAINPOOLP256R1 = 256
    /// The curve identifier for brainpoolP320r1
    case BRAINPOOLP320R1 = 257
    /// The curve identifier for brainpoolP384r1
    case BRAINPOOLP384R1 = 258
    /// The curve identifier for brainpoolP512r1
    case BRAINPOOLP512R1 = 259
    /// The curve identifier for Ed25519 (EdDSA only)
    case ED25519 = 6
    /// The curve identifier for X25519 (ECDH only)
    case X25519 = 4
    /// The curve identifier for Ed448 (EdDSA only)
    case ED448 = 7
    /// The curve identifier for X448 (ECDH only)
    case X448 = 5

    static let coseToJwk: [CoseEcCurve: String] = [
        .P256: "P-256",
        .P384: "P-384",
        .P521: "P-521",
        .ED25519: "Ed25519",
        .ED448: "Ed448",
        .X25519: "X25519",
        .X448: "X448",
        .BRAINPOOLP256R1: "brainpoolP256r1",
        .BRAINPOOLP320R1: "brainpoolP320r1",
        .BRAINPOOLP384R1: "brainpoolP384r1",
        .BRAINPOOLP512R1: "brainpoolP512r1"
    ]

    static let jwkToCose: [String: CoseEcCurve] = [
        "P-256": .P256,
        "P-384": .P384,
        "P-521": .P521,
        "Ed25519": .ED25519,
        "Ed448": .ED448,
        "X25519": .X25519,
        "X448": .X448,
        "brainpoolP256r1": .BRAINPOOLP256R1,
        "brainpoolP320r1": .BRAINPOOLP320R1,
        "brainpoolP384r1": .BRAINPOOLP384R1,
        "brainpoolP512r1": .BRAINPOOLP512R1
    ]

    public static func fromInt(_ coseCurveIdentifier: UInt64) throws -> CoseEcCurve {
        guard let curve = CoseEcCurve(rawValue: coseCurveIdentifier) else {
            throw NSError(domain: "EcCurve", code: -1, userInfo: [NSLocalizedDescriptionKey: "No curve with COSE identifier \(coseCurveIdentifier)"])
        }
        return curve
    }

    public static func fromJwkName(_ jwkName: String) throws -> CoseEcCurve {
        guard let curve = jwkToCose[jwkName] else {
            throw NSError(domain: "EcCurve", code: -1, userInfo: [NSLocalizedDescriptionKey: "No EcCurve value for \(jwkName)"])
        }
        return curve
    }

    /// The curve size in bits
    public var bitSize: Int {
        switch self {
        case .P256, .BRAINPOOLP256R1, .X25519, .ED25519: 256
        case .P384, .BRAINPOOLP384R1: 384
        case .P521: 521
        case .BRAINPOOLP320R1: 320
        case .BRAINPOOLP512R1: 512
        case .X448, .ED448: 448
        }
    }

    /// The name of the curve according to [Standards for Efficient Cryptography Group](https://www.secg.org/).
    public var SECGName: String {
        switch self {
        case .P256: "secp256r1"
        case .P384: "secp384r1"
        case .P521: "secp521r1"
        case .BRAINPOOLP256R1: "brainpoolP256r1"
        case .BRAINPOOLP320R1: "brainpoolP320r1"
        case .BRAINPOOLP384R1: "brainpoolP384r1"
        case .BRAINPOOLP512R1: "brainpoolP512r1"
        case .X25519: "x25519"
        case .ED25519: "ed25519"
        case .X448: "x448"
        case .ED448: "ed448"
        }
    }

     /// The name of the curve according to [JSON Web Key Elliptic Curve](https://www.iana.org/assignments/jose/jose.xhtml#web-key-elliptic-curve)
    public var jwkName: String {
        guard let name = CoseEcCurve.coseToJwk[self] else { fatalError("No JWK entry for \(self)") }
        return name
    }

    /// The default signing algorithm for the curve.
    public var defaultSigningAlgorithm: SigningAlgorithm {
        switch self {
        case .P256, .BRAINPOOLP256R1, .BRAINPOOLP320R1: .ES256
        case .P384, .BRAINPOOLP384R1: .ES384
        case .P521, .BRAINPOOLP512R1: .ES512
        case .ED25519, .ED448: .EDDSA
        case .X25519, .X448: .UNSET
        }
    }
}

/// signing algorithm
public enum SigningAlgorithm: Sendable {
    case ES256
    case ES384
    case ES512
    case EDDSA
    case UNSET
}
