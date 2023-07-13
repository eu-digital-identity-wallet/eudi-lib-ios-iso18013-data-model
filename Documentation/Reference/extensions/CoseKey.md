**EXTENSION**

# `CoseKey`
```swift
extension CoseKey: CBOREncodable
```

## Methods
### `toCBOR(options:)`

```swift
public func toCBOR(options: CBOROptions) -> CBOR
```

### `init(cbor:)`

```swift
public init?(cbor obj: CBOR)
```

### `init(x:y:crv:)`

```swift
public init(x: [UInt8], y: [UInt8], crv: ECCurveType = .p256)
```

### `getx963Representation()`

```swift
public func getx963Representation() -> Data
```

An ANSI x9.63 representation of the public key.
