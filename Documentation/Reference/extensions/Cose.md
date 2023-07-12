**EXTENSION**

# `Cose`
```swift
extension Cose
```

## Methods
### `init(type:cbor:)`

```swift
public init?(type: CoseType, cbor: SwiftCBOR.CBOR)
```

### `init(type:algorithm:signature:)`

```swift
public init(type: CoseType, algorithm: UInt64, signature: Data)
```

initializer to create a detached cose signature

### `init(type:algorithm:payloadData:)`

```swift
public init(type: CoseType, algorithm: UInt64, payloadData: Data)
```

initializer to create a payload cose message

### `init(other:payloadData:)`

```swift
public init(other: Cose, payloadData: Data)
```

### `toCBOR(options:)`

```swift
public func toCBOR(options: CBOROptions) -> CBOR
```
