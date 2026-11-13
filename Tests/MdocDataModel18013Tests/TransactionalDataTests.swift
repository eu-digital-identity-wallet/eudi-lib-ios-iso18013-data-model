import Foundation
import Testing
import SwiftyJSON
@testable import MdocDataModel18013

struct TransactionalDataTests {
    @Test func presentationRoundTripAndLegacyLogs() throws {
        let objects = try TransactionalData(content: [JSON(["type": "example", "nested": ["values": [1, 2]]])])
        let log = TransactionEntry.presentation(.init(transactionIdentifier: "id", time: Date(timeIntervalSince1970: 0),
            transactionResult: .notCompleted, reasonOfNoncompletion: "access_denied", listOfClaimsRequested: [],
            listOfClaimsPresented: [], transactionalData: objects))
        let bytes = try JSONEncoder().encode(log)
        #expect(try JSONDecoder().decode(TransactionEntry.self, from: bytes) == log)
        let legacy = TransactionEntry.presentation(.init(transactionIdentifier: "old", time: Date(timeIntervalSince1970: 0),
            transactionResult: .completed, listOfClaimsRequested: [], listOfClaimsPresented: []))
        #expect(try JSONDecoder().decode(TransactionEntry.self, from: JSONEncoder().encode(legacy)) == legacy)
        let encodedObjects = try JSON(data: JSONEncoder().encode(objects))
        #expect(encodedObjects.array?.count == 1)
        #expect(encodedObjects[0]["nested"]["values"].arrayValue.map(\.intValue) == [1, 2])
    }

    @Test func rejectsInvalidLogPayload() {
        #expect(throws: (any Error).self) { try TransactionalData(content: []) }
        #expect(throws: (any Error).self) { try TransactionalData(content: [JSON("not an object")]) }
        #expect(throws: (any Error).self) { try JSONDecoder().decode(TransactionalData.self, from: Data("[1]".utf8)) }
    }
}
