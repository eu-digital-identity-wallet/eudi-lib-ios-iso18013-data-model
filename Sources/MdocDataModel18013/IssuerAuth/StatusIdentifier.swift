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
import SwiftCBOR

/// A struct representing a status identifier, which includes an index and a URI string.
public struct StatusIdentifier: Codable, Sendable {
    public init(idx: Int, uriString: String) {
        self.idx = idx
        self.uriString = uriString
    }
    public let idx: Int
    public let uriString: String
}

extension StatusIdentifier {
    public init?(data msoRawData: [UInt8]) {
		guard let obj = try? CBOR.decode(msoRawData) else { return nil }
		guard case let CBOR.tagged(tag, cborEncoded) = obj, tag == .encodedCBORDataItem, case let .byteString(bytes) = cborEncoded else { return nil }
		guard let cbor = try? CBOR.decode(bytes), case let .map(m) = cbor, case let .map(status) = m[.utf8String("status")] else { return nil }
		if case let .map(status_list) = status[.utf8String("status_list")], case let .unsignedInt(idx) = status_list[.utf8String("idx")], case let .utf8String(uri) = status_list[.utf8String("uri")] {
			self.idx = Int(idx); uriString = uri
        } else { return nil }
    }
}
