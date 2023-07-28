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
public struct IssuerSignedItem
```

Data item signed by issuer

## Properties
### `digestID`

```swift
public let digestID: UInt64
```

Digest ID for issuer data authentication

### `random`

```swift
let random: [UInt8]
```

Random value for issuer data authentication

### `elementIdentifier`

```swift
public let elementIdentifier: DataElementIdentifier
```

Data element identifier

### `elementValue`

```swift
let elementValue: DataElementValue
```

Data element value

### `rawData`

```swift
public var rawData: [UInt8]?
```

Raw CBOR data
