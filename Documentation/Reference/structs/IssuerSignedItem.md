**STRUCT**

# `IssuerSignedItem`

**Contents**

- [Properties](#properties)
  - `digestID`
  - `elementIdentifier`
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

### `elementIdentifier`

```swift
public let elementIdentifier: DataElementIdentifier
```

Data element identifier

### `rawData`

```swift
public var rawData: [UInt8]?
```

Raw CBOR data
