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

initializer to create a cose message from a cbor representation
 - Parameters:
  - type: Cose message type
  - cbor: CBOR representation of the cose message

### `init(type:algorithm:signature:)`

```swift
public init(type: CoseType, algorithm: UInt64, signature: Data)
```

initializer to create a detached cose signature

### `init(type:algorithm:payloadData:unprotectedHeaderCbor:signature:)`

```swift
public init(type: CoseType, algorithm: UInt64, payloadData: Data, unprotectedHeaderCbor: CBOR? = nil, signature: Data? = nil)
```

initializer to create a payload cose message

### `init(other:payloadData:)`

```swift
public init(other: Cose, payloadData: Data)
```

initializer to create a cose message from a detached cose and a payload
 - Parameters:
 - other: detached cose message
 - payloadData: payload data

### `toCBOR(options:)`

```swift
public func toCBOR(options: CBOROptions) -> CBOR
```
