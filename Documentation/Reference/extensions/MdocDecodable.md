**EXTENSION**

# `MdocDecodable`
```swift
extension MdocDecodable
```

## Methods
### `getItemValue(_:)`

```swift
public func getItemValue<T>(_ s: String) -> T?
```

### `getSignedItems(_:_:_:)`

```swift
public static func getSignedItems(_ response: DeviceResponse, _ docType: String, _ ns: [NameSpace]? = nil) -> [String: [IssuerSignedItem]]?
```

### `extractAgeOverValues(_:_:)`

```swift
public static func extractAgeOverValues(_ nameSpaces: [String: [IssuerSignedItem]], _ ageOverXX: inout [Int: Bool])
```

### `extractDisplayStrings(_:_:)`

```swift
public static func extractDisplayStrings(_ nameSpaces: [String: [IssuerSignedItem]], _ displayStrings: inout [NameValue])
```
