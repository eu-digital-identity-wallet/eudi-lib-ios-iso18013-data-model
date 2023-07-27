**STRUCT**

# `CoseKeyPrivate`

**Contents**

- [Properties](#properties)
  - `key`
  - `d`
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

### `d`

```swift
let d: [UInt8]
```

## Methods
### `init(key:d:)`

```swift
public init(key: CoseKey, d: [UInt8])
```
