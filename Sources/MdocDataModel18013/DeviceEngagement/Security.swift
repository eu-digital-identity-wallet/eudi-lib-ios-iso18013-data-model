//
//  File.swift
//  
//
//  Created by ffeli on 16/05/2023.
//

import Foundation
import SwiftCBOR

/// Security = [int, EDeviceKeyBytes ]
struct Security {
    static let cipherSuiteIdentifier: UInt64 = 1
    // private key for holder only
    public var d: [UInt8]?
    /// security struct. of the holder transfered (only the public key of the mDL is encoded)
    public var deviceKey: CoseKey
}

extension Security: CBOREncodable {
    func toCBOR(options: CBOROptions) -> CBOR {
        CBOR.array([.unsignedInt(Self.cipherSuiteIdentifier), deviceKey.taggedEncoded])
    }
}

extension Security: CBORDecodable {
    init?(cbor: CBOR) {
        guard case let .array(arr) = cbor, arr.count > 1 else { return nil }
        guard case let .unsignedInt(v) = arr[0], v == Self.cipherSuiteIdentifier else { return nil }
        guard let ck = arr[1].decodeTagged(CoseKey.self) else { return nil }
        deviceKey = ck
    }
}
