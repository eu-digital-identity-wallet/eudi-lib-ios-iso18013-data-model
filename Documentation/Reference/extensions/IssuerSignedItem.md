**EXTENSION**

# `IssuerSignedItem`
```swift
extension IssuerSignedItem: CustomStringConvertible
```

## Properties
### `description`

```swift
public var description: String
```

## Methods
### `init(data:)`

```swift
public init?(data: [UInt8])
```

### `init(cbor:)`

```swift
public init?(cbor: CBOR)
```

### `encode(options:)`

```swift
public func encode(options: CBOROptions) -> [UInt8]
```

NOT tagged

### `toCBOR(options:)`

```swift
public func toCBOR(options: CBOROptions) -> CBOR
```
