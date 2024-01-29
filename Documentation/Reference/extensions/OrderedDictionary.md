**EXTENSION**

# `OrderedDictionary`
```swift
extension OrderedDictionary where Key == String, Value == Any
```

## Methods
### `decodeJSON(type:)`

```swift
public func decodeJSON<T: Decodable>(type: T.Type = T.self) -> T?
```
