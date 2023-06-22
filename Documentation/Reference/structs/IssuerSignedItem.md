**STRUCT**

# `IssuerSignedItem`

**Contents**

- [Properties](#properties)
  - `digestID`
  - `random`
  - `elementIdentifier`
  - `elementValue`
  - `rawData`

```swift
struct IssuerSignedItem
```

Data item signed by issuer

## Properties
### `digestID`

```swift
let digestID: UInt64
```

Digest ID for issuer data authentication

### `random`

```swift
let random: [UInt8]
```

Random value for issuer data authentication

### `elementIdentifier`

```swift
let elementIdentifier: DataElementIdentifier
```

Data element identifier

### `elementValue`

```swift
let elementValue: DataElementValue
```

Data element value

### `rawData`

```swift
var rawData: [UInt8]?
```

Raw CBOR data
