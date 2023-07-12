**STRUCT**

# `DocRequest`

**Contents**

- [Properties](#properties)
  - `itemsRequest`
  - `itemsRequestRawData`
  - `readerAuth`
  - `readerAuthRawCBOR`

```swift
public struct DocRequest
```

## Properties
### `itemsRequest`

```swift
public let itemsRequest: ItemsRequest
```

### `itemsRequestRawData`

```swift
public let itemsRequestRawData: [UInt8]?
```

### `readerAuth`

```swift
let readerAuth: ReaderAuth?
```

Used for mdoc reader authentication

### `readerAuthRawCBOR`

```swift
public let readerAuthRawCBOR: CBOR?
```
