import Foundation
import Testing
@testable import MdocDataModel18013

struct SecureAreaErrorHandlingTests {
    @Test func invalidUsageCountsThrowRecoverableError() {
        do {
            _ = try CredentialsUsageCounts(total: 1, remaining: 2)
            Issue.record("Expected invalid usage counts to throw")
        } catch {
            let error = error as NSError
            #expect(error.domain == "CredentialsUsageCounts")
            #expect(error.code == -1)
            #expect(error.localizedDescription == "Total count cannot be less than remaining count")
        }
    }

    @Test func validUsageCountsRemainSupported() throws {
        let counts = try CredentialsUsageCounts(total: 2, remaining: 1)
        #expect(counts.used == 1)
        let unused = try CredentialsUsageCounts(total: 2, remaining: 2)
        #expect(unused.used == 0)
    }

    @Test(arguments: [
        CoseEcCurve.P256, .P384, .P521,
        .BRAINPOOLP256R1, .BRAINPOOLP320R1, .BRAINPOOLP384R1, .BRAINPOOLP512R1,
        .ED25519, .X25519, .ED448, .X448
    ])
    func jwkNamesRoundTrip(curve: CoseEcCurve) throws {
        let name = try curve.jwkName
        #expect(try CoseEcCurve.fromJwkName(name) == curve)
    }
}
