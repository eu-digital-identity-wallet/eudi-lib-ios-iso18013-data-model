**STRUCT**

# `Security`

**Contents**

- [Properties](#properties)
  - `cipherSuiteIdentifier`
  - `d`
  - `deviceKey`

```swift
struct Security
```

Security = [int, EDeviceKeyBytes ]

## Properties
### `cipherSuiteIdentifier`

```swift
static let cipherSuiteIdentifier: UInt64 = 1
```

### `d`

```swift
public var d: [UInt8]?
```

### `deviceKey`

```swift
public var deviceKey: CoseKey
```

security struct. of the holder transfered (only the public key of the mDL is encoded)
