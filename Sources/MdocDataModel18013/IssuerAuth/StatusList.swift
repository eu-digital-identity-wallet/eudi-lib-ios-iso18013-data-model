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

public struct Status: Decodable, Sendable {
	public let statusList: StatusList

	enum CodingKeys: String, CodingKey {
		case statusList = "status_list"
	}
}
/// A struct representing a status list, which includes an index and a URI string.
public struct StatusList: Codable, Sendable {
    public init(idx: Int, uri: String) {
        self.idx = idx
        self.uri = uri
    }
    enum CodingKeys: String, CodingKey {
		case idx = "idx"
		case uri = "uri"
	}
    public let idx: Int
    public let uri: String
}

extension StatusList {
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
            idx = Int(statusIndex)
            uri = statusUri
        } else { return nil }
    }
}
