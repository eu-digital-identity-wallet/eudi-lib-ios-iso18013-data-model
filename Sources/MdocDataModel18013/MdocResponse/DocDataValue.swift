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
#if os(iOS)
import UIKit
#endif

public enum DocDataValue: Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    /// A boolean value.
    case boolean(Bool)
    /// An integer value.
    case integer(UInt64)
    /// A double value.
    case double(Double)
    /// A string value.
    case string(String)
    /// A date value.
    case date(String)
 	/// Bytes value
 	case bytes([UInt8])
    /// An array value.
    case array
    /// A dictionary value.
    case dictionary
#if os(iOS)
    public var image: UIImage? {
        switch self {
        case .bytes(let bytes):
            return UIImage(data: Data(bytes))
        default:
            return nil
        }
    }
#endif
    public var base64: String? {
        switch self {
        case .bytes(let bytes):
            return Data(bytes).base64EncodedString()
        default:
            return nil
        }
    }
    public var dateValue: Date? {
        switch self {
        case .date(let str):
            let dateFormatter = ISO8601DateFormatter()
            return dateFormatter.date(from: str)
       default:
            return nil
        }
    }

    public var description: String {
        switch self {
        case .boolean(let b): String(b)
        case .integer(let i): String(i)
        case .double(let d): String(d)
        case .string(let s): s
        case .date(let d): d
        case .bytes(let b): "Bytes \(b.count)"
        case .array: "Array"
        case .dictionary: "Dictionary"
        }
    }

    public var debugDescription: String {
        switch self {
        case .bytes(let b): base64 ?? "Bytes \(b.count)"
        default: description
        }
    }
}
