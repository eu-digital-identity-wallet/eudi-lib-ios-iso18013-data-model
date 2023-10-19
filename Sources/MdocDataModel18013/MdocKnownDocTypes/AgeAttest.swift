/*
Copyright (c) 2023 European Commission

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

	public func max2AgesOver(ages: [Int]) -> [Int:Bool] {
		guard ages.count > 2 else { return Dictionary(grouping: ages, by: { $0 }).mapValues { _ in true } }
		let sortedAges = ages.sorted()
		var res = Dictionary(grouping: sortedAges, by: { $0 }).mapValues { _ in false }
		var numAges = 0
		for age in sortedAges {
			if isOver(age: age) != nil, numAges < 2 {
				numAges += 1
				res[age] = true
			}
		}
		return res
	}
	
	public func max2AgesOverFiltered(ages: [Int]) -> [Int] { Array(max2AgesOver(ages: ages).filter { $1 }.keys).sorted() }
	
}

public struct SimpleAgeAttest: AgeAttest {
	public var ageOverXX = [Int: Bool]()
	
	public init(ageOver1: Int, isOver1: Bool, ageOver2: Int, isOver2: Bool) {
		ageOverXX[ageOver1] = isOver1
		ageOverXX[ageOver2] = isOver2
	}
	
	public init(namespaces: [NameSpace: [IssuerSignedItem]]) {
		GenericMdocModel.self.extractAgeOverValues(namespaces, &ageOverXX)
	}
} // end struct
