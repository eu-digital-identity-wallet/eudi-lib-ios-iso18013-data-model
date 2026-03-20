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
import OrderedCollections

/// Represents a document that contains a zero-knowledge (ZK) proof.
///
/// - Parameters:
///   - documentData: The structured data of the document.
///   - proof: The ZK proof that attests to the integrity and validity of the document data.
public struct ZkDocument: Sendable {
    public let documentData: ZkDocumentData
    public let proof: Data

    public init(documentData: ZkDocumentData, proof: Data) {
        self.documentData = documentData
        self.proof = proof
    }
}

/// Converts this ZkDocument instance to a CBOR representation.
///
/// The resulting CBOR will be a map containing two entries:
/// - "proof": The proof as a CBOR byte string
/// - "documentData": The document data serialized to its CBOR representation
///
/// - Returns: A CBOR value representing this ZkDocument
extension ZkDocument: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var map: OrderedDictionary<CBOR,CBOR> = [:]
        map[CBOR.utf8String("proof")] = CBOR.byteString([UInt8](proof))

        // Encode documentData to CBOR bytes and wrap in tagged CBOR
        let documentDataCBOR = documentData.toCBOR(options: options)
        let encodedDocumentData = documentDataCBOR.encode()
        map[CBOR.utf8String("documentData")] = CBOR.tagged(.encodedCBORDataItem, CBOR.byteString([UInt8](encodedDocumentData)))
        return CBOR.map(map)
    }
}

/// Creates a ZkDocument instance from a CBOR representation.
///
/// This deserializes a CBOR representation back into a ZkDocument object.
/// It expects the CBOR to be a map with the following required fields:
/// - "proof": A CBOR byte string containing the ZK proof
/// - "documentData": A CBOR structure that can be deserialized into ZkDocumentData
///
/// - Parameter dataItem: The CBOR value to deserialize
/// - Returns: A new ZkDocument instance
/// - Throws: An error if required fields are missing or have invalid types
extension ZkDocument: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(cborMap) = cbor else { throw .invalidCbor("ZkDocument") }
        guard case let .byteString(proofBytes)? = cborMap[CBOR.utf8String("proof")] else { throw .missingField("ZkDocument", "proof") }
        guard let documentDataCBOR = cborMap[CBOR.utf8String("documentData")] else { throw .missingField("ZkDocument", "documentData") }
        // Extract tagged byte string (tag 24 for encoded CBOR)
        guard case let .tagged(tag, .byteString(encodedBytes)) = documentDataCBOR, tag == .encodedCBORDataItem else { throw .invalidCbor("ZkDocument") }
        // Decode the nested CBOR
        guard let decodedCBOR = try? CBOR.decode([UInt8](encodedBytes)) else { throw .invalidCbor("ZkDocument") }
        let documentData = try ZkDocumentData(cbor: decodedCBOR)
        self.init(documentData: documentData, proof: Data(proofBytes))
    }
}

