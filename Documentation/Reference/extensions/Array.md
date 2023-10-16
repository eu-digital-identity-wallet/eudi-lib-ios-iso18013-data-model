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
public func findDoc(name: String) -> DocRequest?
```

### `findNameValue(name:)`

```swift
public func findNameValue(name: String) -> NameValue?
```

### `findItem(name:)`

```swift
public func findItem(name: String) -> IssuerSignedItem?
```

### `findMap(name:)`

```swift
public func findMap(name: String) -> [CBOR:CBOR]?
```

### `findArray(name:)`

```swift
public func findArray(name: String) -> [CBOR]?
```
