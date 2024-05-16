**PROTOCOL**

# `MdocDecodable`

```swift
public protocol MdocDecodable: AgeAttesting
```

A conforming type represents mdoc data.

Can be decoded by a CBOR device response

## Properties
### `id`

```swift
var id: String
```

### `createdAt`

```swift
var createdAt: Date
```

### `docType`

```swift
var docType: String
```

### `response`

```swift
var response: DeviceResponse?
```

### `devicePrivateKey`

```swift
var devicePrivateKey: CoseKeyPrivate?
```

### `nameSpaces`

```swift
var nameSpaces: [NameSpace]?
```

### `title`

```swift
var title: String
```

### `mandatoryElementKeys`

```swift
var mandatoryElementKeys: [DataElementIdentifier]
```

### `displayStrings`

```swift
var displayStrings: [NameValue]
```

### `displayImages`

```swift
var displayImages: [NameImage]
```

## Methods
### `toJson(base64:)`

```swift
func toJson(base64: Bool) -> [String: Any]
```
