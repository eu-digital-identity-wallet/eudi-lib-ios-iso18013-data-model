**STRUCT**

# `Security`

**Contents**

- [Properties](#properties)
  - `cipherSuiteIdentifier`
  - `d`
  - `deviceKey`
- [Methods](#methods)
  - `setD(d:)`

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
var d: [UInt8]?
```

### `deviceKey`

```swift
let deviceKey: CoseKey
```

security struct. of the holder transfered (only the public key of the mDL is encoded)

## Methods
### `setD(d:)`

```swift
mutating func setD(d: [UInt8])
```
