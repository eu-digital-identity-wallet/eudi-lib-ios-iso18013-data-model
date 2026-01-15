import Foundation
import SwiftCBOR

/// Protocol representing a Zero-Knowledge Proof system that can generate and verify proofs
/// for identity documents according to the ISO/IEC 18013-5 standard.
public protocol ZkSystemProtocol {
    /// The unique name identifying this ZK system implementation.
    var name: String { get }

    /// A list of all ZkSystemSpecs supported by this ZK system. Each spec describes
    /// the parameters and configuration for a supported circuit or proof scheme.
    var systemSpecs: [ZkSystemSpec] { get }

    /// Generates a zero-knowledge proof for a given document using the specified zkSystemSpec
    /// and session context.
    ///
    /// - Parameters:
    ///   - zkSystemSpec: The system spec indicating which ZK circuit or rules to use
    ///   - document: The MdocDocument to generate a proof for.
    ///   - sessionTranscript: The Session Transcript used for the document.
    ///   - timestamp: The timestamp for the proof generation (defaults to current time)
    /// - Returns: A ZkDocument containing the resulting proof and metadata
    func generateProof(zkSystemSpec: ZkSystemSpec, document: Document, sessionTranscriptBytes: [UInt8], timestamp: Date) throws -> ZkDocument

    /// Verifies a zero-knowledge proof in the given zkDocument using the provided session context.
    ///
    /// - Parameters:
    ///   - zkDocument: The document containing the proof and associated metadata
    ///   - zkSystemSpec: The system spec used to generate the proof
    ///   - sessionTranscript: The Session Transcript used for the document.
    /// - Throws: ProofVerificationFailureException if the proof is invalid or cannot be verified
    func verifyProof(zkDocument: ZkDocument, zkSystemSpec: ZkSystemSpec, sessionTranscriptBytes: [UInt8]) throws

    /// Searches through the provided zkSystemSpecs and returns the first one that is
    /// compatible with the given document.
    ///
    /// This is used during proof generation to select the correct spec for a document instance.
    ///
    /// - Parameters:
    ///   - zkSystemSpecs: The list of specs available from the device request
    ///   - requestedClaims: The requested claims.
    /// - Returns: A compatible ZkSystemSpec, or nil if none match
    func getMatchingSystemSpec(zkSystemSpecs: [ZkSystemSpec], numAttributesRequested: Int64) -> ZkSystemSpec?
}

public struct RequestedClaim {
    // TODO: Implement based on actual RequestedClaim structure
}
