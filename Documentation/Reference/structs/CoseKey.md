**STRUCT**

# `CoseKey`

**Contents**

- [Properties](#properties)
  - `crv`
  - `kty`
  - `x`
  - `y`

```swift
struct CoseKey: Equatable
```

COSE_Key as defined in RFC 8152

## Properties
### `crv`

```swift
let crv: ECCurveType
```

EC identifier

### `kty`

```swift
var kty: UInt64 = 2
```

key type

### `x`

```swift
let x: [UInt8]
```

value of x-coordinate

### `y`

```swift
let y: [UInt8]
```

value of y-coordinate
