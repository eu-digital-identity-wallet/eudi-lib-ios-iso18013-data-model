//
//  AgeAttest.swift

import Foundation

/// A conforming type contains age attestation values
public protocol AgeAttest {
  var ageOverXX: [Int: Bool] { get }
}

/// Age attestation: Nearest “true” attestation above request (7.2.5 of iso document)
extension AgeAttest {
  func isOver(age: Int) -> (key: Int, value: Bool)? {
	if let overTrue = ageOverXX.filter({ (key, value) in value == true && key >= age}).sorted(by: { $0.key < $1.key}).first
	{ return overTrue}
	if let overFalse = ageOverXX.filter({ (key, value) in value == false && key <= age}).sorted(by: { $0.key > $1.key}).first
	{ return overFalse}
	return nil
  }
}
