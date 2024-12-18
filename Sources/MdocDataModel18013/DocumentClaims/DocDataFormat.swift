import Foundation
/// Format of document data
/// ``cbor``: IssuerSigned struct cbor encoded
/// ``sdjwt``: vc+sd-jwt encoded
///
/// Raw value must be a 4-length string due to keychain requirements
public enum DocDataFormat: String, Sendable, CustomStringConvertible, CustomDebugStringConvertible, Codable {
	case cbor = "cbor"
	case sdjwt = "sjwt"

    /// A description to display
    public var description: String {
        switch self {
        case .cbor: return "mso_mdoc"
        case .sdjwt: return "vc+sd-jwt"
        }
    }

    public var debugDescription: String {
        description
    }
}