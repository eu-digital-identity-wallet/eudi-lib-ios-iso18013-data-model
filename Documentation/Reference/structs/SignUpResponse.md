**STRUCT**

# `SignUpResponse`

**Contents**

- [Properties](#properties)
  - `response`
  - `pin`
  - `privateKey`
  - `deviceResponse`
  - `devicePrivateKey`

```swift
public struct SignUpResponse: Codable
```

Signup response encoded as base64

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

### `devicePrivateKey`

```swift
public var devicePrivateKey: CoseKeyPrivate?
```
