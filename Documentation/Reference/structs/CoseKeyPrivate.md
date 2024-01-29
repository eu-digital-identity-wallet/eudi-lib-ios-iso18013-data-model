**STRUCT**

# `CoseKeyPrivate`

**Contents**

- [Properties](#properties)
  - `key`
  - `secureEnclaveKeyID`
- [Methods](#methods)
  - `init(key:d:)`

```swift
public struct CoseKeyPrivate
```

COSE_Key + private key

## Properties
### `key`

```swift
public let key: CoseKey
```

### `secureEnclaveKeyID`

```swift
public let secureEnclaveKeyID: Data?
```

## Methods
### `init(key:d:)`

```swift
public init(key: CoseKey, d: [UInt8])
```
