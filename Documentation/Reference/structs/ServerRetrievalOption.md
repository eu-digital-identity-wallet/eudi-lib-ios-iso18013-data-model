**STRUCT**

# `ServerRetrievalOption`

**Contents**

- [Properties](#properties)
  - `versionImpl`
  - `version`
  - `url`
  - `token`

```swift
struct ServerRetrievalOption: Codable, Equatable
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
var url: String
```

### `token`

```swift
var token: String
```
