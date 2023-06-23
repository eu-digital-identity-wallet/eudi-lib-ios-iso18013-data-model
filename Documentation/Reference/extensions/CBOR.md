**EXTENSION**

# `CBOR`
```swift
extension CBOR
```

## Properties
### `description`

```swift
public var description: String
```

## Methods
### `unwrap()`

```swift
public func unwrap() -> Any?
```

### `asUInt64()`

```swift
public func asUInt64() -> UInt64?
```

### `asDouble()`

```swift
public func asDouble() -> Double?
```

### `asInt64()`

```swift
public func asInt64() -> Int64?
```

### `asString()`

```swift
public func asString() -> String?
```

### `asList()`

```swift
public func asList() -> [CBOR]?
```

### `asMap()`

```swift
public func asMap() -> [CBOR:CBOR]?
```

### `asBytes()`

```swift
public func asBytes() -> [UInt8]?
```

### `asData()`

```swift
public func asData() -> Data
```

### `asCose()`

```swift
public func asCose() -> (CBOR.Tag, [CBOR])?
```

### `decodeBytestring()`

```swift
public func decodeBytestring() -> CBOR?
```

### `decodeList(_:)`

```swift
public static func decodeList(_ list: [CBOR]) -> [Any]
```

### `decodeDictionary(_:)`

```swift
public static func decodeDictionary(_ dictionary: [CBOR:CBOR]) -> [String: Any]
```
