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
import SwiftCBOR

extension CBOR {
    /// Decode one complete mdoc CBOR item, including maps nested inside it.
    static func decodeMdoc(_ bytes: [UInt8]) throws -> CBOR? {
        let stream = MdocCBORInputStream(bytes)
        let decoder = CBORDecoder(stream: stream, options: CBOROptions(rejectDuplicateMapKeys: true))
        let item = try decoder.decodeItem()
        guard stream.remaining.isEmpty else { throw MdocValidationError.cborDecodingError }
        return item
    }
}

/// Reference semantics let the caller check consumption without re-encoding signed data.
private final class MdocCBORInputStream: CBORInputStream {
    var remaining: ArraySlice<UInt8>

    init(_ bytes: [UInt8]) {
        remaining = bytes[...]
    }

    func popByte() throws -> UInt8 {
        guard let byte = remaining.popFirst() else { throw CBORError.unfinishedSequence }
        return byte
    }

    func popBytes(_ count: Int) throws -> ArraySlice<UInt8> {
        guard count >= 0, remaining.count >= count else { throw CBORError.unfinishedSequence }
        let bytes = remaining.prefix(count)
        remaining = remaining.dropFirst(count)
        return bytes
    }
}
