**EXTENSION**

# `Data`
```swift
extension Data
```

## Properties
### `bytes`

```swift
public var bytes: Array<UInt8>
```

## Methods
### `init(name:ext:from:)`

```swift
public init?(name: String, ext: String = "json", from bundle:Bundle = Bundle.main)
```

init from local file

### `decodeJSON(type:)`

```swift
public func decodeJSON<T: Decodable>(type: T.Type = T.self) -> T?
```

### `init(base64URLEncoded:options:)`

```swift
public init?(base64URLEncoded: String, options: Data.Base64DecodingOptions = [])
```

Decodes a base64-url encoded string to data.

https://tools.ietf.org/html/rfc4648#page-7

### `init(base64URLEncoded:options:)`

```swift
public init?(base64URLEncoded: Data, options: Data.Base64DecodingOptions = [])
```

Decodes base64-url encoded data.

https://tools.ietf.org/html/rfc4648#page-7

### `base64URLEncodedString(options:)`

```swift
public func base64URLEncodedString(options: Data.Base64EncodingOptions = []) -> String
```

Encodes data to a base64-url encoded string.

https://tools.ietf.org/html/rfc4648#page-7

- parameter options: The options to use for the encoding. Default value is `[]`.
- returns: The base64-url encoded string.

#### Parameters

| Name | Description |
| ---- | ----------- |
| options | The options to use for the encoding. Default value is `[]`. |

### `base64URLEncodedData(options:)`

```swift
public func base64URLEncodedData(options: Data.Base64EncodingOptions = []) -> Data
```

Encodes data to base64-url encoded data.

https://tools.ietf.org/html/rfc4648#page-7

- parameter options: The options to use for the encoding. Default value is `[]`.
- returns: The base64-url encoded data.

#### Parameters

| Name | Description |
| ---- | ----------- |
| options | The options to use for the encoding. Default value is `[]`. |

### `base64URLUnescape()`

```swift
public mutating func base64URLUnescape()
```

Converts base64-url encoded data to a base64 encoded data.

https://tools.ietf.org/html/rfc4648#page-7

### `base64URLEscape()`

```swift
public mutating func base64URLEscape()
```

Converts base64 encoded data to a base64-url encoded data.

https://tools.ietf.org/html/rfc4648#page-7

### `base64URLUnescaped()`

```swift
public func base64URLUnescaped() -> Data
```

Converts base64-url encoded data to a base64 encoded data.

https://tools.ietf.org/html/rfc4648#page-7

### `base64URLEscaped()`

```swift
public func base64URLEscaped() -> Data
```

Converts base64 encoded data to a base64-url encoded data.

https://tools.ietf.org/html/rfc4648#page-7
