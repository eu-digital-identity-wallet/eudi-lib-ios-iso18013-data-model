**STRUCT**

# `SignUpResponse`

**Contents**

- [Properties](#properties)
  - `response`
  - `pin`
  - `privateKey`
  - `deviceResponse`
  - `devicePrivateKey`
- [Methods](#methods)
  - `decomposeCBORDeviceResponse(data:)`
  - `decomposeCBORSignupResponse(data:)`

```swift
public struct SignUpResponse: Codable
```

Signup response json-encoded

## Properties
### `response`

```swift
public let response: String?
```

### `pin`

```swift
public let pin: String?
```

### `privateKey`

```swift
public let privateKey: String?
```

### `deviceResponse`

```swift
public var deviceResponse: DeviceResponse?
```

Device response decoded from base64-encoded string

### `devicePrivateKey`

```swift
public var devicePrivateKey: CoseKeyPrivate?
```

Device private key decoded from base64-encoded string

## Methods
### `decomposeCBORDeviceResponse(data:)`

```swift
public static func decomposeCBORDeviceResponse(data: Data) -> [(docType: String, dr: MdocDataModel18013.DeviceResponse)]?
```

Decompose CBOR device responses from data

A data file may contain signup responses with many documents (doc.types).
- Parameter data: Data from file or memory
- Returns:  separate ``MdocDataModel18013.DeviceResponse`` objects for each doc.type

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | Data from file or memory |

### `decomposeCBORSignupResponse(data:)`

```swift
public static func decomposeCBORSignupResponse(data: Data) -> [(docType: String, jsonData: Data, drData: Data, pkData: Data?)]?
```

Decompose CBOR signup responses from data

A data file may contain signup responses with many documents (doc.types).
- Parameter data: Data from file or memory
- Returns:  separate json serialized signup response objects for each doc.type

#### Parameters

| Name | Description |
| ---- | ----------- |
| data | Data from file or memory |