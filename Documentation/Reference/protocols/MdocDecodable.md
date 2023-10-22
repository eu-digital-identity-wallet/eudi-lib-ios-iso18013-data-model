**PROTOCOL**

# `MdocDecodable`

```swift
public protocol MdocDecodable: AgeAttesting
```

A conforming type represents mdoc data.

Can be decoded by a CBOR device response

## Properties
### `response`

```swift
var response: DeviceResponse?
```

### `devicePrivateKey`

```swift
var devicePrivateKey: CoseKeyPrivate?
```

### `docType`

```swift
var docType: String
```

### `nameSpaces`

```swift
var nameSpaces: [NameSpace]?
```

### `title`

```swift
var title: String
```

### `displayStrings`

```swift
var displayStrings: [NameValue]
```
