**STRUCT**

# `GenericMdocModel`

**Contents**

- [Properties](#properties)
  - `response`
  - `devicePrivateKey`
  - `docType`
  - `nameSpaces`
  - `title`
  - `ageOverXX`
  - `displayStrings`

```swift
public struct GenericMdocModel: MdocDecodable
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
public var docType: String
```

### `nameSpaces`

```swift
public var nameSpaces: [NameSpace]?
```

### `title`

```swift
public var title: String
```

### `ageOverXX`

```swift
public var ageOverXX = [Int: Bool]()
```

### `displayStrings`

```swift
public var displayStrings = [NameValue]()
```
