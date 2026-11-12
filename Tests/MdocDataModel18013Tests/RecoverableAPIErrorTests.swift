import Foundation
import SwiftCBOR
import Testing
@testable import MdocDataModel18013

struct RecoverableAPIErrorTests {
    private func expectNSError(domain: String, operation: () throws -> Void) {
        do {
            try operation()
            Issue.record("Expected an NSError from \(domain)")
        } catch {
            let error = error as NSError
            #expect(error.domain == domain)
            #expect(error.code == -1)
            #expect(error.userInfo[NSLocalizedDescriptionKey] is String)
        }
    }

    @Test func emptyRegistryThrows() {
        let registry = SecureAreaRegistry()
        for name in [nil, "missing"] as [String?] {
            expectNSError(domain: "SecureAreaRegistry") { _ = try registry.get(name: name) }
        }
        #expect(registry.defaultSecurityArea == nil)
    }

    @Test func emptyConstructedAndDecodedPathsThrow() throws {
        let decoded = try JSONDecoder().decode(ClaimPath.self, from: Data("[]".utf8))
        for path in [ClaimPath([]), decoded] {
            expectNSError(domain: "ClaimPath") { _ = try path.head() }
            expectNSError(domain: "ClaimPath") { _ = try path.component1() }
            #expect(path.parent() == nil)
            #expect(path.tail() == nil)
        }
        let path = ClaimPath.claim("family_name")
        #expect(try path.head() == .claim(name: "family_name"))
        #expect(try path.component1() == path.head())
    }

    @Test(arguments: ["", "gg", "0x10", String(repeating: "f", count: 32)])
    func invalidHexIntegersThrow(input: String) {
        expectNSError(domain: "HexDecoding") { _ = try input.hex_decimal }
    }

    @Test func validHexIntegers() throws {
        #expect(try "aF".hex_decimal == 175)
        #expect(try String(Int.max, radix: 16).hex_decimal == Int.max)
    }

    @Test(arguments: ["0", "abc", "gg", "-1", "+1", "00 0", "é0"])
    func invalidHexBytesThrow(input: String) {
        expectNSError(domain: "HexDecoding") { _ = try input.byteArray }
    }

    @Test func validHexBytes() throws {
        #expect(try "".byteArray.isEmpty)
        #expect(try "00aAFF".byteArray == [0, 170, 255])
    }

    @Test func invalidDrivingPrivilegeIndicesThrow() throws {
        let empty = try DrivingPrivileges(cbor: .array([]))
        let populated = try DrivingPrivileges(cbor: .array([.map([.utf8String("vehicle_category_code"): .utf8String("B")])]))
        for index in [Int.min, -1, 0, Int.max] {
            expectNSError(domain: "DrivingPrivileges") { _ = try empty[index] }
        }
        for index in [Int.min, -1, 1, Int.max] {
            expectNSError(domain: "DrivingPrivileges") { _ = try populated[index] }
        }
        #expect(try populated[0].vehicleCategoryCode == "B")
    }

    @Test func uuidEncodingPreservesByteOrder() throws {
        let uuid = try #require(UUID(uuidString: "00112233-4455-6677-8899-AABBCCDDEEFF"))
        let expected: [UInt8] = [0, 17, 34, 51, 68, 85, 102, 119, 136, 153, 170, 187, 204, 221, 238, 255]
        for peripheralMode in [false, true] {
            let method = DeviceRetrievalMethod.ble(peripheralServerMode: peripheralMode, uuid: uuid)
            let encoded = method.toCBOR(options: CBOROptions())
            guard case let .array(values) = encoded, values.count == 3,
                  case let .map(options) = values[2] else {
                Issue.record("Expected BLE retrieval options")
                return
            }
            #expect(options[peripheralMode ? 10 : 11] == .byteString(expected))
            #expect(try DeviceRetrievalMethod(cbor: encoded) == method)
        }
    }
}
