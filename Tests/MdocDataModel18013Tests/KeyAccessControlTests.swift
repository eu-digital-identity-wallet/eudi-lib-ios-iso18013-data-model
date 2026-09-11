import Foundation
import MdocDataModel18013
import Security
import Testing

@Suite("Key Access Control Tests")
struct KeyAccessControlTests {

    /// Every named case and the keychain flags it must produce.
    static let namedCases: [(accessControl: KeyAccessControl, expected: SecAccessControlCreateFlags)] = [
        (.requireUserPresence, .userPresence),
        (.requireBiometryAny, .biometryAny),
        (.requireBiometryCurrentSet, .biometryCurrentSet),
    ]

    @Test("named cases map to the native flag bits")
    func testNamedCasesMapToNativeFlagBits() {
        #expect(SecAccessControlCreateFlags.userPresence.rawValue == 1 << 0)
        #expect(KeyAccessControl.requireUserPresence.flags == .userPresence)

        #expect(SecAccessControlCreateFlags.biometryAny.rawValue == 1 << 1)
        #expect(KeyAccessControl.requireBiometryAny.flags == .biometryAny)

        #expect(SecAccessControlCreateFlags.biometryCurrentSet.rawValue == 1 << 3)
        #expect(KeyAccessControl.requireBiometryCurrentSet.flags == .biometryCurrentSet)
    }

    @Test("init(flags:) recognises the flags of every named case", arguments: namedCases)
    func testInitFromFlagsRecognisesNamedCases(namedCase: (accessControl: KeyAccessControl, expected: SecAccessControlCreateFlags)) {
        #expect(KeyAccessControl(flags: namedCase.expected) == namedCase.accessControl)
        #expect(KeyAccessControl(flags: namedCase.accessControl.flags) == namedCase.accessControl)
    }

    @Test("custom passes its flags through unchanged", arguments: [
        SecAccessControlCreateFlags([]),
        [.biometryCurrentSet, .or, .devicePasscode],
        [.biometryCurrentSet, .and, .applicationPassword],
        [.devicePasscode],
        SecAccessControlCreateFlags(rawValue: 1 << 20), // a bit this SDK does not name at all
    ])
    func testCustomPassesFlagsThrough(flags: SecAccessControlCreateFlags) {
        #expect(KeyAccessControl.custom(flags).flags == flags)
    }

    @Test("flags that match no named case become custom")
    func testUnrecognisedFlagsBecomeCustom() {
        let fallback: SecAccessControlCreateFlags = [.biometryCurrentSet, .or, .devicePasscode]
        #expect(KeyAccessControl(flags: fallback) == .custom(fallback))
        #expect(KeyAccessControl(flags: []) == .custom([]))
        // no bit is silently dropped on the way back out
        #expect(KeyAccessControl(flags: fallback).flags == fallback)
    }

    @Test("custom holding a single named flag is equivalent to that named case")
    func testCustomWithNamedFlagIsEquivalent() {
        // .custom is not == the named case, but both produce the same keychain flags and normalise to the same value
        #expect(KeyAccessControl.custom(.biometryCurrentSet).flags == KeyAccessControl.requireBiometryCurrentSet.flags)
        #expect(KeyAccessControl(flags: KeyAccessControl.custom(.biometryCurrentSet).flags) == .requireBiometryCurrentSet)
    }

    @Test("named cases round-trip through Codable", arguments: namedCases)
    func testNamedCasesRoundTripThroughCodable(namedCase: (accessControl: KeyAccessControl, expected: SecAccessControlCreateFlags)) throws {
        let decoded = try roundTrip(namedCase.accessControl)

        #expect(decoded == namedCase.accessControl)
        #expect(decoded.flags == namedCase.expected)
    }

    @Test("custom round-trips through Codable")
    func testCustomRoundTripsThroughCodable() throws {
        let accessControl = KeyAccessControl.custom([.biometryCurrentSet, .or, .devicePasscode])

        #expect(try roundTrip(accessControl) == accessControl)
    }

    private func roundTrip(_ accessControl: KeyAccessControl) throws -> KeyAccessControl {
        let data = try JSONEncoder().encode([accessControl])
        return try JSONDecoder().decode([KeyAccessControl].self, from: data)[0]
    }
}

// a simple OptionSet to test the remove and insert methods
@Suite("ShippingOptions Tests")
struct ShippingOptionsTests {

    struct ShippingOptions: OptionSet {
        let rawValue: Int

        static let nextDay    = ShippingOptions(rawValue: 1 << 0)
        static let secondDay  = ShippingOptions(rawValue: 1 << 1)
        static let priority   = ShippingOptions(rawValue: 1 << 2)
        static let standard   = ShippingOptions(rawValue: 1 << 3)

        static let express: ShippingOptions = [.nextDay, .secondDay]
        static let all: ShippingOptions = [.express, .priority, .standard]
    }

    @Test("remove returns the removed option and mutates the set")
    func testRemoveOption() {
        var options: ShippingOptions = [.secondDay, .priority]
        let (bool, inserted) = options.insert(.priority)
        #expect(bool == false)
        #expect(inserted == .priority)
        let priorityOption = options.remove(.priority)
        #expect(priorityOption == .priority)
        #expect(options == [.secondDay])
        #expect(!options.contains(.priority))
    }
}
