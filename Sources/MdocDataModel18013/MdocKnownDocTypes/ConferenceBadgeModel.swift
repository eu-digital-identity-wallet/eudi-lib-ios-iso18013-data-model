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

//  EuPidModel.swift

import Foundation

public struct ConferenceBadgeModel: Codable, MdocDecodable {
	public var response: DeviceResponse?
	public var devicePrivateKey: CoseKeyPrivate?
	public var docType = "com.example.conference.badge"
	public var nameSpaces: [NameSpace]?
	public var title = String("conference_badge")
	
	public let family_name: String?
	public let given_name: String?
	public let expiry_date: String?
	public let registration_id: UInt64?
	public let room_number: UInt64?
	public let seat_number: UInt64?

	public enum CodingKeys: String, CodingKey, CaseIterable {
		case family_name
		case given_name
		case expiry_date
		case registration_id
		case room_number
		case seat_number
	}
	public var ageOverXX = [Int: Bool]()
	public var displayStrings = [NameValue]()
	public var displayImages = [NameImage]()
    public var mandatoryElementKeys: [DataElementIdentifier] { [] }
}

extension ConferenceBadgeModel {
	public init?(response: DeviceResponse, devicePrivateKey: CoseKeyPrivate) {
		self.response = response; self.devicePrivateKey = devicePrivateKey
		guard let nameSpaces = Self.getSignedItems(response, docType) else { return nil }
		Self.extractDisplayStrings(nameSpaces, &displayStrings, &displayImages)
		Self.extractAgeOverValues(nameSpaces, &ageOverXX)
		func getValue<T>(key: ConferenceBadgeModel.CodingKeys) -> T? { Self.getItemValue(nameSpaces, string: key.rawValue) }
		family_name = getValue(key: .family_name)
		given_name = getValue(key: .given_name)
		expiry_date = getValue(key: .expiry_date)
		registration_id = getValue(key: .registration_id)
		room_number = getValue(key: .room_number)
		seat_number = getValue(key: .seat_number)
	}
}

