**STRUCT**

# `ConferenceBadgeModel`

**Contents**

- [Properties](#properties)
  - `response`
  - `devicePrivateKey`
  - `docType`
  - `nameSpaces`
  - `title`
  - `family_name`
  - `given_name`
  - `expiry_date`
  - `registration_id`
  - `room_number`
  - `seat_number`
  - `ageOverXX`
  - `displayStrings`
  - `displayImages`
  - `mandatoryElementKeys`

```swift
public struct ConferenceBadgeModel: Codable, MdocDecodable
```

## Properties
### `response`

```swift
public var response: DeviceResponse?
```

### `devicePrivateKey`

```swift
public var devicePrivateKey: CoseKeyPrivate?
```

### `docType`

```swift
public var docType = "com.example.conference.badge"
```

### `nameSpaces`

```swift
public var nameSpaces: [NameSpace]?
```

### `title`

```swift
public var title = String("conference_badge")
```

### `family_name`

```swift
public let family_name: String?
```

### `given_name`

```swift
public let given_name: String?
```

### `expiry_date`

```swift
public let expiry_date: String?
```

### `registration_id`

```swift
public let registration_id: UInt64?
```

### `room_number`

```swift
public let room_number: UInt64?
```

### `seat_number`

```swift
public let seat_number: UInt64?
```

### `ageOverXX`

```swift
public var ageOverXX = [Int: Bool]()
```

### `displayStrings`

```swift
public var displayStrings = [NameValue]()
```

### `displayImages`

```swift
public var displayImages = [NameImage]()
```

### `mandatoryElementKeys`

```swift
public var mandatoryElementKeys: [DataElementIdentifier]
```
