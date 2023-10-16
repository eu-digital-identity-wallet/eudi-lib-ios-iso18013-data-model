**STRUCT**

# `ServerRetrievalOption`

**Contents**

- [Properties](#properties)
  - `versionImpl`
  - `version`
  - `url`
  - `token`

```swift
public struct ServerRetrievalOption: Codable, Equatable
```

Server retrieval information

## Properties
### `versionImpl`

```swift
static var versionImpl: UInt64
```

### `version`

```swift
var version: UInt64 = Self.versionImpl
```

### `url`

```swift
public var url: String
```

### `token`

```swift
public var token: String
```
