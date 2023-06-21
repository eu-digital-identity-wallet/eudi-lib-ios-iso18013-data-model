**STRUCT**

# `CoseKeyPrivate`

**Contents**

- [Properties](#properties)
  - `key`
  - `d`
- [Methods](#methods)
  - `init(crv:)`

```swift
struct CoseKeyPrivate
```

COSE_Key + private key

## Properties
### `key`

```swift
let key: CoseKey
```

### `d`

```swift
let d: [UInt8]
```

## Methods
### `init(crv:)`

```swift
init(crv: ECCurveType)
```
