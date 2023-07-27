**EXTENSION**

# `Array`
```swift
extension Array where Element == UInt8
```

## Properties
### `taggedEncoded`

```swift
public var taggedEncoded: CBOR
```

## Methods
### `toHexString()`

```swift
public func toHexString() -> String
```

### `findDoc(name:)`

```swift
public func findDoc(name: String) -> Document?
```

### `findDoc(name:)`

```swift
public func findDoc(name: String) -> ItemsRequest?
```

### `findItem(name:)`

```swift
public func findItem(name: String) -> IssuerSignedItem?
```
