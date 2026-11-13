/*
 * Copyright (c) 2026 European Commission
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy at http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
@preconcurrency import SwiftyJSON

/// The decoded transaction objects carried by a presentation request (TS10 §3.19.12).
/// Encodes as an array, preserving all type-specific fields for later display.
public struct TransactionalData: Codable, Equatable, Sendable {
    public let content: [JSON]

    public init(content: [JSON]) throws {
        guard !content.isEmpty, content.allSatisfy({ $0.dictionary != nil }) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Transactional data must be a non-empty array of objects"))
        }
        self.content = content
    }

    public init(from decoder: Decoder) throws {
        try self.init(content: decoder.singleValueContainer().decode([JSON].self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(content)
    }
}
