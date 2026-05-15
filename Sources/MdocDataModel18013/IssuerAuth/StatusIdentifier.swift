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
        guard case let CBOR.tagged(tag, encodedCbor) = obj,
              tag == .encodedCBORDataItem,
              case let .byteString(encodedBytes) = encodedCbor
        else { return nil }

        guard let cbor = try? CBOR.decode(encodedBytes),
              case let .map(msoMap) = cbor,
              case let .map(statusMap) = msoMap[.utf8String("status")]
        else { return nil }

        if case let .map(statusListMap) = statusMap[.utf8String("status_list")],
           case let .unsignedInt(statusIndex) = statusListMap[.utf8String("idx")],
           case let .utf8String(statusUri) = statusListMap[.utf8String("uri")]
        {
            self.idx = Int(statusIndex)
            uriString = statusUri
        } else { return nil }
    }
}
