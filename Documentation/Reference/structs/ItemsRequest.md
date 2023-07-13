**STRUCT**

# `ItemsRequest`

**Contents**

- [Properties](#properties)
  - `docType`
  - `nameSpaces`
  - `requestInfo`

```swift
public struct ItemsRequest
```

## Properties
### `docType`

```swift
public let docType: DocType
```

Requested document type.

### `nameSpaces`

```swift
public let nameSpaces: RequestNameSpaces
```

Requested data elements for each NameSpace

### `requestInfo`

```swift
let requestInfo: CBOR?
```

May be used by the mdoc reader to provide additional information
