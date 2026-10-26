/*
Copyright (c) 2026 European Commission

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

import Testing
@testable import MdocDataModel18013

struct SessionEstablishmentClaimTests {
    @Test func copiesShareTheEstablishmentClaim() throws {
        let engagement = try #require(DeviceEngagement(supportsCentralClientMode: true, supportsPeripheralServerMode: false))
        let copy = engagement
        #expect(engagement.claimSessionEstablishment())
        #expect(!copy.claimSessionEstablishment())
    }

    @Test func concurrentClaimsAcceptOnlyOneEstablishment() async throws {
        let engagement = try #require(DeviceEngagement(supportsCentralClientMode: true, supportsPeripheralServerMode: false))
        let accepted = await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<32 { group.addTask { engagement.claimSessionEstablishment() } }
            var count = 0
            for await claimed in group where claimed { count += 1 }
            return count
        }
        #expect(accepted == 1)
    }

    @Test func onlyFreshKeyGenerationResetsTheClaim() async throws {
        var engagement = try #require(DeviceEngagement(supportsCentralClientMode: true, supportsPeripheralServerMode: false))
        #expect(engagement.claimSessionEstablishment())
        let old = engagement
        try await engagement.makePrivateKey(secureArea: InMemoryP256SecureArea(storage: DummySecureKeyStorage()), keyOptions: .init(curve: .P256))
        #expect(engagement.claimSessionEstablishment())
        #expect(!old.claimSessionEstablishment())
    }
    @Test func terminationRevokesCopiesAndOnlyNewKeyResetsLifetime() async throws {
        var engagement = try #require(DeviceEngagement(supportsCentralClientMode: true, supportsPeripheralServerMode: false))
        let copy = engagement
        engagement.invalidateSession()
        #expect(copy.isSessionTerminated)
        #expect(!copy.claimSessionEstablishment())
        try await engagement.makePrivateKey(secureArea: InMemoryP256SecureArea(storage: DummySecureKeyStorage()), keyOptions: .init(curve: .P256))
        #expect(!engagement.isSessionTerminated)
        #expect(engagement.claimSessionEstablishment())
        #expect(copy.isSessionTerminated)
    }

}
