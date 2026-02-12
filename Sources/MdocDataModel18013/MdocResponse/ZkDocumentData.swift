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

/// ZkDocumentData contains the data the proof will prove.
///
/// - Parameters:
///   - zkSystemSpecId: The ZK system spec Id from the verifier used to create the proof.
///   - docType: The doc type of doc being represented.
///   - timestamp: The timestamp the proof was generated at.
///   - issuerSigned: Issuer signed name spaces and values.
///   - deviceSigned: Devices signed name spaces and values.
///   - msoX5chain: The issuers certificate chain.
public struct ZkDocumentData: Sendable {
    public let zkSystemSpecId: String
    public let docType: String
    public let timestamp: Date
    public let issuerSigned: [String: [String: CBOR]]
    public let deviceSigned: [String: [String: CBOR]]
    public let msoX5chain: [[UInt8]]?

    public init(zkSystemSpecId: String, docType: String, timestamp: Date, issuerSigned: [String: [String: CBOR]], deviceSigned: [String: [String: CBOR]], msoX5chain: [[UInt8]]?) {
        self.zkSystemSpecId = zkSystemSpecId
        self.docType = docType
        self.timestamp = timestamp
        self.issuerSigned = issuerSigned
        self.deviceSigned = deviceSigned
        self.msoX5chain = msoX5chain
    }
}

    /// Converts this ZkDocumentData instance to a CBOR representation.
    ///
    /// The resulting CBOR will be a map containing:
    /// - "zkSystemId": The ZK system specification identifier as a text string
    /// - "docType": The document type as a text string
    /// - "timestamp": The timestamp as a `tdate` w/ no fractional seconds and using Zulu timezone.
    /// - "issuerSignedItems": An array of issuer-signed data items
    /// - "deviceSignedItems": An array of device-signed data items
    /// - "msoX5chain": The X.509 certificate chain (only included if non-null)
    ///
    /// - Returns: A CBOR value representing this ZkDocumentData
extension ZkDocumentData: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var map: OrderedDictionary<CBOR,CBOR> = [:]
        map[CBOR.utf8String("zkSystemId")] = CBOR.utf8String(zkSystemSpecId)
        map[CBOR.utf8String("docType")] = CBOR.utf8String(docType)
        // Format timestamp as ISO-8601 string with Zulu timezone
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(identifier: "UTC")
        var timestampStr = formatter.string(from: timestamp)
        // Remove fractional seconds to whole seconds only
        if let dotIndex = timestampStr.firstIndex(of: ".") {
            //let endIndex = timestampStr.index(dotIndex, offsetBy: 1)
            timestampStr = String(timestampStr[..<dotIndex]) + "Z"
        }
        map[CBOR.utf8String("timestamp")] = CBOR.tagged(CBOR.Tag(rawValue: 0), CBOR.utf8String(timestampStr))
        // Encode issuerSigned
        var issuerSignedMap: OrderedDictionary<CBOR,CBOR> = [:]
        for (namespaceName, dataElements) in issuerSigned {
            var elementsArray: [CBOR] = []
            for (dataElementName, dataElementValue) in dataElements {
                var elementMap: OrderedDictionary<CBOR,CBOR> = [:]
                elementMap[CBOR.utf8String("elementIdentifier")] = CBOR.utf8String(dataElementName)
                elementMap[CBOR.utf8String("elementValue")] = dataElementValue
                elementsArray.append(CBOR.map(elementMap))
            }
            issuerSignedMap[CBOR.utf8String(namespaceName)] = CBOR.array(elementsArray)
        }
        map[CBOR.utf8String("issuerSigned")] = CBOR.map(issuerSignedMap)
        // Encode deviceSigned
        var deviceSignedMap: OrderedDictionary<CBOR,CBOR> = [:]
        for (namespaceName, dataElements) in deviceSigned {
            var elementsArray: [CBOR] = []
            for (dataElementName, dataElementValue) in dataElements {
                var elementMap: OrderedDictionary<CBOR,CBOR> = [:]
                elementMap[CBOR.utf8String("elementIdentifier")] = CBOR.utf8String(dataElementName)
                elementMap[CBOR.utf8String("elementValue")] = dataElementValue
                elementsArray.append(CBOR.map(elementMap))
            }
            deviceSignedMap[CBOR.utf8String(namespaceName)] = CBOR.array(elementsArray)
        }
        map[CBOR.utf8String("deviceSigned")] = CBOR.map(deviceSignedMap)
        // Encodes the certificate chain as CBOR. If the chain has only one item a .byteString with the sole certificate is returned. Otherwise an array of [.byteString] is returned.
        if let msoX5chain = msoX5chain {
            if msoX5chain.count == 1 {
                map[CBOR.utf8String("msoX5chain")] = CBOR.byteString(msoX5chain[0])
            } else {
                map[CBOR.utf8String("msoX5chain")] = CBOR.array(msoX5chain.map { CBOR.byteString($0) })
            }
        }
        return CBOR.map(map)
    }
}

    /// Creates a ZkDocumentData instance from a CBOR representation.
    ///
    /// This factory method deserializes a CBOR representation back into a ZkDocumentData object.
    /// It validates and extracts all required fields from the CBOR map structure.
    ///
    /// Expected CBOR structure:
    /// - "zkSystemId": Required text string for the ZK system specification ID
    /// - "docType": Required text string for the document type
    /// - "timestamp": Required text string in ISO-8601 format
    /// - "issuerSignedItems": Optional array of DataItems (defaults to empty list)
    /// - "deviceSignedItems": Optional array of DataItems (defaults to empty list)
    /// - "msoX5chain": Required X.509 certificate chain
    ///
    /// - Parameter dataItem: The CBOR value to deserialize
    /// - Returns: A new ZkDocumentData instance
    /// - Throws: An error if required fields are missing or have invalid types
extension ZkDocumentData: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case let .map(cborMap) = cbor else { throw .invalidCbor("ZkDocumentData") }
        guard case let .utf8String(zkSystemSpecId)? = cborMap[CBOR.utf8String("zkSystemId")] else { throw .missingField("ZkDocumentData", "zkSystemId") }
        guard case let .utf8String(docType) = cborMap[CBOR.utf8String("docType")] else { throw .missingField("ZkDocumentData", "docType") }
        guard let taggedTimestamp = cborMap[CBOR.utf8String("timestamp")] else { throw .missingField("ZkDocumentData", "timestamp") }
        // Extract tagged timestamp (tag 0 for date-time string)
        guard case let .tagged(tag, .utf8String(timestampStr)) = taggedTimestamp, tag.rawValue == 0 else { throw .invalidCbor("ZkDocumentData") }
        // Parse ISO-8601 timestamp
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let timestamp = formatter.date(from: timestampStr) else { throw .invalidCbor("ZkDocumentData") }
        // Parse issuerSigned
        var issuerSigned: [String: [String: CBOR]] = [:]
        if case let .map(issuerSignedMap)? = cborMap[CBOR.utf8String("issuerSigned")] {
            for (namespaceItem, dataElementsItem) in issuerSignedMap {
                guard case let .utf8String(namespaceName) = namespaceItem,
                      case let .array(dataElementsArray) = dataElementsItem else {
                    continue
                }
                var dataElementsMap: [String: CBOR] = [:]
                for zkSignedItem in dataElementsArray {
                    guard case let .map(itemMap) = zkSignedItem,
                          case let .utf8String(elementId)? = itemMap[CBOR.utf8String("elementIdentifier")],
                          let elementValue = itemMap[CBOR.utf8String("elementValue")] else {
                        continue
                    }
                    dataElementsMap[elementId] = elementValue
                }
                issuerSigned[namespaceName] = dataElementsMap
            }
        }
        // Parse deviceSigned
        var deviceSigned: [String: [String: CBOR]] = [:]
        if case let .map(deviceSignedMap)? = cborMap[CBOR.utf8String("deviceSigned")] {
            for (namespaceItem, dataElementsItem) in deviceSignedMap {
                guard case let .utf8String(namespaceName) = namespaceItem,
                      case let .array(dataElementsArray) = dataElementsItem else {
                    continue
                }
                var dataElementsMap: [String: CBOR] = [:]
                for zkSignedItem in dataElementsArray {
                    guard case let .map(itemMap) = zkSignedItem,
                          case let .utf8String(elementId)? = itemMap[CBOR.utf8String("elementIdentifier")],
                          let elementValue = itemMap[CBOR.utf8String("elementValue")] else {
                        continue
                    }
                    dataElementsMap[elementId] = elementValue
                }
                deviceSigned[namespaceName] = dataElementsMap
            }
        }
        // Parse msoX5chain
        var msoX5chain: [[UInt8]]? = nil
        if let msoX5chainItem = cborMap[CBOR.utf8String("msoX5chain")] {
            switch msoX5chainItem {
            case .byteString(let certBytes): msoX5chain = [certBytes]
            case .array(let certArray):
                // Multiple certificates
                var certs: [[UInt8]] = []
                for certItem in certArray {
                    if case let .byteString(certBytes) = certItem { certs.append(certBytes)}
                }
                msoX5chain = certs
            default: throw .invalidCbor("ZkDocumentData")
            }
        }
        self.init(zkSystemSpecId: zkSystemSpecId, docType: docType, timestamp: timestamp, issuerSigned: issuerSigned, deviceSigned: deviceSigned, msoX5chain: msoX5chain)
    }
}


