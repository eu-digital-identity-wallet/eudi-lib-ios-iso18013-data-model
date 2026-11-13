import SwiftCBOR

/// Validates the wire shape only; certificate trust remains the verifier's responsibility.
enum CertificateChain {
    static func decode(_ cbor: CBOR) throws(MdocValidationError) -> [[UInt8]] {
        let entries: [CBOR]
        switch cbor {
        case .byteString: entries = [cbor]
        case .array(let values): entries = values
        default: throw .invalidCbor("certificate chain must be bytes or an array of bytes")
        }
        guard !entries.isEmpty else { throw .invalidCbor("certificate chain must not be empty") }
        return try entries.map { entry throws(MdocValidationError) in
            guard case let .byteString(bytes) = entry, !bytes.isEmpty else {
                throw .invalidCbor("certificate chain entries must be nonempty byte strings")
            }
            return bytes
        }
    }
}
