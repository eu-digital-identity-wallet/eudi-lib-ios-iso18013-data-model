//
//  Cose.swift

import Foundation
import SwiftCBOR
import Security

extension Cose {
    /// COSE Message Identification
    public enum CoseType : String {
        /// COSE Single Signer Data Object
        /// Only one signature is applied on the message payload
        case sign1 = "Signature1"
        /// COSE Signed Data Object
        /// One or more signature is applied on the message payload
        case sign = "Signature"
        
        /// Identtifies Cose Message Type from input data
        static func from(data: Data) -> CoseType? {
            guard let cose = try? CBORDecoder(input: data.bytes).decodeItem()?.asCose() else {
                return nil
            }
            
            switch cose.0 {
            case .coseSign1Item:
                return .sign1
                
            case .coseSignItem:
                return .sign
                
            default:
                return nil
            }
        }
    }
    
}

extension Cose {
    
    public struct CoseHeader {
        
        // ======================================================================
        // MARK: - Public
        // ======================================================================

        public enum Headers : Int {
            case keyId = 4
            case algorithm = 1
        }
        
        public enum Algorithm : UInt64 {
            case es256 = 6 //-7
            case ps256 = 36 //-37
        }
        
        // MARK: - Public Properties
        
        public let rawHeader : CBOR?
        public let keyId : [UInt8]?
        public let algorithm : Algorithm?
        
        // MARK: - Initializers
        
        init?(fromBytestring cbor: CBOR){
            guard let cborMap = cbor.decodeBytestring()?.asMap(),
                  let algValue = cborMap[Headers.algorithm]?.asUInt64(),
                  let alg = Algorithm(rawValue: algValue) else {
				self.init(alg: nil, keyId: nil, rawHeader: cbor)
                return
            }
            
            self.init(alg: alg, keyId: cborMap[Headers.keyId]?.asBytes(), rawHeader: cbor)
        }
        
        init?(from cbor: CBOR) {
            let cborMap = cbor.asMap()
            var alg : Algorithm?
           
            if let algValue = cborMap?[Headers.algorithm]?.asUInt64() {
                alg = Algorithm(rawValue: algValue)
            }
            
            self.init(alg: alg, keyId: cborMap?[Headers.keyId]?.asBytes())
        }
        
        // MARK: - Private
        
        private init(alg: Algorithm?, keyId: [UInt8]?, rawHeader : CBOR? = nil){
            self.algorithm = alg
            self.keyId = keyId
            self.rawHeader = rawHeader
        }
        
    }
    
}

/**
 
 Struct which describes  a representation for cryptographic keys;
 how to create and process signatures, message authentication codes, and
 encryption using Concise Binary Object Representation (CBOR) or serialization.
 
 */

public struct Cose {
    
    // ======================================================================
    // MARK: - Public
    // ======================================================================
    
    // MARK: - Public Properties
    
    public let type: CoseType
    public let protectedHeader : CoseHeader
    public let unprotectedHeader : CoseHeader?
    public let payload : CBOR
    public let signature : Data
    
    public var keyId : Data? {
        get {
            var keyData : Data?
            
            if let unprotectedKeyId = unprotectedHeader?.keyId {
                keyData = Data(unprotectedKeyId)
            }
            
            if let protectedKeyId = protectedHeader.keyId {
                keyData = Data(protectedKeyId)
            }
            
            return keyData
        }
    }
    
    public var signatureStruct : Data? {
        get {
            guard let header = protectedHeader.rawHeader else {
                return nil
            }
            
            /* Structure according to https://tools.ietf.org/html/rfc8152#section-4.2 */
            switch type {
            case .sign1:
                let context = CBOR(stringLiteral: self.type.rawValue)
                let externalAad = CBOR.byteString([UInt8]()) /*no external application specific data*/
                let cborArray = CBOR(arrayLiteral: context, header, externalAad, payload)
                return Data(cborArray.encode())
                
            default:
                print("COSE Sign messages are not yet supported.")
                return nil
            }
        }
    }
    
    // MARK: - Initializer
    
    public init?(from data: Data) {
        let cborType = CborType.from(data: data)
        switch cborType {
        case .tag:
            guard let cose = try? CBOR.decode(data.bytes)?.asCose(),
                  let protectedHeader = CoseHeader(fromBytestring: cose.1[0]),
                  let signature = cose.1[3].asBytes(),
                  let type = CoseType.from(data: data) else {
                return nil
            }
            
            self.type = type
            self.protectedHeader = protectedHeader
            self.unprotectedHeader = CoseHeader(from: cose.1[1])
            self.payload = cose.1[2]
            self.signature = Data(signature)
            
        case .list:
            guard let coseData = try? CBOR.decode(data.bytes),
                  let coseList = coseData.asList(),
                  let protectedHeader = CoseHeader(fromBytestring: coseList[0]),
                  let signature = coseList[3].asBytes() else {
                return nil
            }
            
            self.protectedHeader = protectedHeader
            self.unprotectedHeader = CoseHeader(fromBytestring: coseList[1]) ?? nil
            self.payload = coseList[2]
            self.signature = Data(signature)
            self.type = .sign1
            
        case .cwt:
            guard let rawCose = try? CBORDecoder(input: data.bytes).decodeItem(),
                  let cwtCose = rawCose.unwrap() as? (CBOR.Tag, CBOR),
                  let coseData = cwtCose.1.unwrap() as? (CBOR.Tag, CBOR),
                  let coseList = coseData.1.asList(),
                  let protectedHeader = CoseHeader(fromBytestring: coseList[0]),
                  let signature = coseList[3].asBytes() else {
                return nil
            }
            
            self.protectedHeader = protectedHeader
            self.unprotectedHeader = CoseHeader(fromBytestring: coseList[1]) ?? nil
            self.payload = coseList[2]
            self.signature = Data(signature)
            self.type = .sign1
            
        case .unknown:
            print("Unknown CBOR type.")
            return nil
        }
    }
    
}

