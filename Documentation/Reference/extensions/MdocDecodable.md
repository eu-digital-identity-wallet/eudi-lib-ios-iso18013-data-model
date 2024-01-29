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

### `toJson(base64:)`

```swift
public func toJson(base64: Bool = false) -> [String: Any]
```

### `extractAgeOverValues(_:_:)`

```swift
public static func extractAgeOverValues(_ nameSpaces: [NameSpace: [IssuerSignedItem]], _ ageOverXX: inout [Int: Bool])
```

### `moreThan2AgeOverElementIdentifiers(_:_:_:_:)`

```swift
public static func moreThan2AgeOverElementIdentifiers(_ reqDocType: DocType, _ reqNamespace: NameSpace, _ ageAttest: any AgeAttesting, _ reqElementIdentifiers: [DataElementIdentifier]) -> Set<String>
```

### `extractDisplayStringOrImage(_:_:_:_:_:_:)`

```swift
public static func extractDisplayStringOrImage(_ name: String, _ cborValue: CBOR, _ bDebugDisplay: Bool, _ displayImages: inout [NameImage], _ ns: NameSpace, _ order: Int) -> NameValue
```

### `extractDisplayStrings(_:_:_:)`

```swift
public static func extractDisplayStrings(_ nameSpaces: [NameSpace: [IssuerSignedItem]], _ displayStrings: inout [NameValue], _ displayImages: inout [NameImage])
```
