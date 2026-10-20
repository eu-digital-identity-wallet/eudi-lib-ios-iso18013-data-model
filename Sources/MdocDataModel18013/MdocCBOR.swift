import SwiftCBOR

/// The byte boundary for externally supplied CBOR, including embedded CBOR.
enum MdocCBOR {
    static let maximumDepth = 64

    static func decode(_ bytes: [UInt8]) throws -> CBOR? {
        var validator = StructureValidator(bytes: bytes)
        try validator.item(depth: 0)
        return try CBOR.decode(bytes, options: CBOROptions(maximumDepth: maximumDepth))
    }

    /// Checks container sizes before SwiftCBOR can reserve a declared array length.
    private struct StructureValidator {
        let bytes: [UInt8]
        var offset = 0

        mutating func byte() throws -> UInt8 {
            guard offset < bytes.count else { throw MdocValidationError.invalidCbor("truncated CBOR") }
            defer { offset += 1 }
            return bytes[offset]
        }

        mutating func argument(_ info: UInt8) throws -> UInt64 {
            if info < 24 { return UInt64(info) }
            guard info <= 27 else { throw MdocValidationError.invalidCbor("invalid CBOR argument") }
            var result: UInt64 = 0
            for _ in 0..<(1 << (info - 24)) { result = (result << 8) | UInt64(try byte()) }
            return result
        }

        mutating func item(depth: Int) throws {
            guard depth <= MdocCBOR.maximumDepth else { throw MdocValidationError.invalidCbor("CBOR nesting limit") }
            let initial = try byte()
            let major = initial >> 5
            let info = initial & 31
            if info == 31 {
                guard (2...5).contains(major) else { throw MdocValidationError.invalidCbor("unexpected CBOR break") }
                while true {
                    guard offset < bytes.count else { throw MdocValidationError.invalidCbor("unterminated CBOR") }
                    if bytes[offset] == 0xff { offset += 1; break }
                    if major == 2 || major == 3 {
                        guard bytes[offset] >> 5 == major, bytes[offset] & 31 != 31 else {
                            throw MdocValidationError.invalidCbor("invalid indefinite string chunk")
                        }
                    }
                    try item(depth: depth + 1)
                    if major == 5 { try item(depth: depth + 1) }
                }
                return
            }
            let count = try argument(info)
            switch major {
            case 0, 1, 7: return
            case 2, 3:
                guard count <= UInt64(bytes.count - offset) else { throw MdocValidationError.invalidCbor("truncated CBOR string") }
                offset += Int(count)
            case 4, 5:
                let width = major == 5 ? 2 : 1
                // Every child occupies at least one byte. Never multiply an untrusted count.
                guard count <= UInt64((bytes.count - offset) / width) else {
                    throw MdocValidationError.invalidCbor("CBOR container exceeds remaining input")
                }
                for _ in 0..<Int(count) {
                    try item(depth: depth + 1)
                    if major == 5 { try item(depth: depth + 1) }
                }
            case 6: try item(depth: depth + 1)
            default: throw MdocValidationError.invalidCbor("invalid CBOR type")
            }
        }
    }
}
