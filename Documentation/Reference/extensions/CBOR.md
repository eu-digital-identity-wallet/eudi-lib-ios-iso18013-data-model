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

### `debugDescription`

```swift
public var debugDescription: String
```

### `mdocDataType`

```swift
public var mdocDataType: MdocDataType?
```

## Methods
### `decodeTaggedBytes()`

```swift
public func decodeTaggedBytes() -> [UInt8]?
```

### `decodeTagged(_:)`

```swift
public func decodeTagged<T: CBORDecodable>(_ t: T.Type = T.self) -> T?
```

### `decodeFullDate()`

```swift
public func decodeFullDate() -> String?
```

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

### `asDateString(_:_:)`

```swift
public static func asDateString(_ tag: Tag, _ value: CBOR) -> Any
```

### `asCose()`

```swift
public func asCose() -> (CBOR.Tag, [CBOR])?
```

### `decodeBytestring()`

```swift
public func decodeBytestring() -> CBOR?
```

### `decodeList(_:unwrap:base64:)`

```swift
public static func decodeList(_ list: [CBOR], unwrap: Bool = true, base64: Bool = false) -> [Any]
```

### `decodeDictionary(_:unwrap:base64:)`

```swift
public static func decodeDictionary(_ dictionary: [CBOR:CBOR], unwrap: Bool = true, base64: Bool = false) -> [String: Any]
```

### `decodeCborVal(_:unwrap:base64:)`

```swift
public static func decodeCborVal(_ val: CBOR, unwrap: Bool, base64: Bool) -> Any
```
