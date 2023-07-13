**EXTENSION**

# `DocRequest`
```swift
extension DocRequest: CBORDecodable
```

## Properties
### `readerCertificate`

```swift
public var readerCertificate: Data?
```

## Methods
### `init(cbor:)`

```swift
public init?(cbor: CBOR)
```

### `toCBOR(options:)`

```swift
public func toCBOR(options: CBOROptions) -> CBOR
```
