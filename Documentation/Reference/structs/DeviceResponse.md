**STRUCT**

# `DeviceResponse`

**Contents**

- [Properties](#properties)
  - `version`
  - `defaultVersion`
  - `documents`
  - `documentErrors`
  - `status`
- [Methods](#methods)
  - `init(version:documents:documentErrors:status:)`

```swift
public struct DeviceResponse
```

Device retrieval mdoc response. It is CBOR encoded

In mdoc reader initialize from CBOR data received from holder (data exchange)
In mdoc holder initialize from CBOR data received from server (registration)

```swift
let dr = DeviceResponse(data: bytes)
```

## Properties
### `version`

```swift
public let version: String
```

### `defaultVersion`

```swift
static let defaultVersion = "1.0"
```

### `documents`

```swift
public let documents: [Document]?
```

An array of all returned documents

### `documentErrors`

```swift
public let documentErrors: [DocumentError]?
```

An array of all returned document errors

### `status`

```swift
public let status: UInt64
```

## Methods
### `init(version:documents:documentErrors:status:)`

```swift
public init(version: String? = nil, documents: [Document]? = nil, documentErrors: [DocumentError]? = nil, status: UInt64)
```
