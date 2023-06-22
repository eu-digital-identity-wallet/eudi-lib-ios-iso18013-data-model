**STRUCT**

# `DeviceRequest`

**Contents**

- [Properties](#properties)
  - `currentVersion`
  - `version`
  - `docRequests`

```swift
struct DeviceRequest
```

Device retrieval mdoc request structure
In mDoc holder initialize a ``DeviceRequest`` with incoming CBOR bytes (decoding)
```swift
let dr = DeviceRequest(data: bytes)
```
In mdoc reader initialize a ``DeviceRequest`` with desired elements to read 
```swift
let isoKeys: [IsoMdlModel.CodingKeys] = [.familyName, .documentNumber, .drivingPrivileges, .issueDate, .expiryDate, .portrait]
let dr3 = DeviceRequest(mdl: isoKeys, agesOver: [18,21], intentToRetain: true)
```

## Properties
### `currentVersion`

```swift
static let currentVersion = "1.0"
```

The current version

### `version`

```swift
let version: String
```

The version requested

### `docRequests`

```swift
let docRequests: [DocRequest]
```

An array of all requested documents.
