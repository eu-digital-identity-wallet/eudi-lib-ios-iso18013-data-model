**STRUCT**

# `IssuerAuth`

**Contents**

- [Properties](#properties)
  - `mso`
  - `verifyAlgorithm`
  - `signature`
  - `iaca`
- [Methods](#methods)
  - `init(mso:msoRawData:verifyAlgorithm:signature:iaca:)`

```swift
public struct IssuerAuth
```

## Properties
### `mso`

```swift
public let mso: MobileSecurityObject
```

### `verifyAlgorithm`

```swift
public let verifyAlgorithm: Cose.VerifyAlgorithm
```

one or more certificates

### `signature`

```swift
public let signature: Data
```

### `iaca`

```swift
public let iaca: [[UInt8]]
```

## Methods
### `init(mso:msoRawData:verifyAlgorithm:signature:iaca:)`

```swift
public init(mso: MobileSecurityObject, msoRawData: [UInt8], verifyAlgorithm: Cose.VerifyAlgorithm, signature: Data, iaca: [[UInt8]])
```
