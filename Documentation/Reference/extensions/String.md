**EXTENSION**

# `String`
```swift
extension String
```

## Properties
### `hex_decimal`

```swift
public var hex_decimal: Int
```

### `byteArray`

```swift
public var byteArray: [UInt8]
```

## Methods
### `base64URLUnescaped()`

```swift
public func base64URLUnescaped() -> String
```

Converts a base64-url encoded string to a base64 encoded string.

https://tools.ietf.org/html/rfc4648#page-7

### `base64URLEscaped()`

```swift
public func base64URLEscaped() -> String
```

Converts a base64 encoded string to a base64-url encoded string.

https://tools.ietf.org/html/rfc4648#page-7

### `base64URLUnescape()`

```swift
public mutating func base64URLUnescape()
```

Converts a base64-url encoded string to a base64 encoded string.

https://tools.ietf.org/html/rfc4648#page-7

### `base64URLEscape()`

```swift
public mutating func base64URLEscape()
```

Converts a base64 encoded string to a base64-url encoded string.

https://tools.ietf.org/html/rfc4648#page-7

### `toBytes()`

```swift
public func toBytes() -> [UInt8]?
```
