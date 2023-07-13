**STRUCT**

# `DeviceResponse`

**Contents**

- [Properties](#properties)
  - `version`
  - `documents`
  - `documentErrors`
  - `status`

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
let version: String
```

### `documents`

```swift
let documents: [Document]?
```

An array of all returned documents

### `documentErrors`

```swift
let documentErrors: [DocumentError]?
```

An array of all returned document errors

### `status`

```swift
let status: UInt64
```
