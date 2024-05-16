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
  - `displayImages`
  - `mandatoryElementKeys`

```swift
public struct GenericMdocModel: MdocDecodable
```

## Properties
### `id`

```swift
public var id: String = UUID().uuidString
```

### `createdAt`

```swift
public var createdAt: Date = Date()
```

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

### `displayImages`

```swift
public var displayImages = [NameImage]()
```

### `mandatoryElementKeys`

```swift
public var mandatoryElementKeys: [DataElementIdentifier] = []
```
