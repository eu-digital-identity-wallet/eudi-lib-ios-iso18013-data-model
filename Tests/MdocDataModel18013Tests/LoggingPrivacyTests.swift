import Foundation
import Logging
import SwiftCBOR
import Testing
import struct os.OSAllocatedUnfairLock
@testable import MdocDataModel18013

struct LoggingPrivacyTests {
    private struct CaptureHandler: LogHandler {
        let messages: OSAllocatedUnfairLock<[String]>
        var logLevel: Logger.Level = .trace
        var metadata: Logger.Metadata = [:]

        subscript(metadataKey key: String) -> Logger.Metadata.Value? {
            get { metadata[key] }
            set { metadata[key] = newValue }
        }

        func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
            let entry = "\(message) \(self.metadata) \(metadata ?? [:])"
            messages.withLock { $0.append(entry) }
        }
    }

    @Test func keyIdentifiersAreAbsentFromVerboseLogs() async throws {
        let messages = OSAllocatedUnfairLock(initialState: [String]())
        let capture = Logger(label: "privacy-test") { _ in CaptureHandler(messages: messages) }
        let keyID = "private-key-handle-privacy-canary"
        let unlockID = "unlock-key-handle-privacy-canary"
        let area = InMemoryP256SecureArea(storage: DummySecureKeyStorage())

        try await MdocLogging.$logger.withValue(capture) {
            let reference = CoseKeyPrivate(privateKeyId: keyID, index: 0, secureArea: area, curve: .P256)
            #expect(reference.privateKeyId == keyID)
            let result = try await area.unlockKey(id: unlockID)
            #expect(result == nil)
        }

        let entries = messages.withLock { $0 }
        // Ensure capture includes the synchronous initializer and async default unlock path.
        #expect(entries.count == 2)
        #expect(entries.contains { $0.contains("Initializing COSE private key reference") })
        #expect(entries.contains { $0.contains("Using default secure-area key unlock") })
        #expect(!entries.contains { $0.contains(keyID) || $0.contains(unlockID) })
    }

    @Test func engagementSerializationDoesNotLogPayloadAtTraceLevel() throws {
        let messages = OSAllocatedUnfairLock(initialState: [String]())
        let capture = Logger(label: "privacy-test") { _ in CaptureHandler(messages: messages) }
        var engagement = try DeviceEngagement(data: MdocDataModel18013Tests.AnnexdTestData.d31.bytes)
        engagement.originInfos = [OriginInfoWebsite(baseUrl: "https://privacy-canary.example")]
        engagement.updatePsm(12345)

        MdocLogging.$logger.withValue(capture) {
            logger.trace("capture-active")
            let encoded = engagement.toCBOR(options: CBOROptions())
            #expect(encoded[1] != nil)
            #expect(encoded[2] != nil)
            #expect(encoded[5] != nil)
        }

        let entries = messages.withLock { $0 }
        #expect(entries.count == 1)
        #expect(entries.first?.hasPrefix("capture-active ") == true)
    }
}
