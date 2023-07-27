**PROTOCOL**

# `MdocDecodable`

```swift
public protocol MdocDecodable: AgeAttest
```

A conforming type represents mdoc data.

Can be decoded by a CBOR device response

## Properties
### `response`

```swift
var response: DeviceResponse?
```

### `namespace`

```swift
static var namespace: String
```

### `docType`

```swift
static var docType: String
```

### `title`

```swift
static var title: String
```

### `displayStrings`

```swift
var displayStrings: [NameValue]
```

## Methods
### `init(response:)`

```swift
init?(response: DeviceResponse)
```
