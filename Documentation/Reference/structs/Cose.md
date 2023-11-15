**STRUCT**

# `Cose`

**Contents**

- [Properties](#properties)
  - `type`
  - `payload`
  - `signature`
  - `verifyAlgorithm`
  - `macAlgorithm`
  - `signatureStruct`

```swift
public struct Cose
```

Struct which describes  a representation for cryptographic keys;  how to create and process signatures, message authentication codes, and  encryption using Concise Binary Object Representation (CBOR) or serialization.

## Properties
### `type`

```swift
public let type: CoseType
```

### `payload`

```swift
public let payload : CBOR
```

### `signature`

```swift
public let signature : Data
```

### `verifyAlgorithm`

```swift
public var verifyAlgorithm: VerifyAlgorithm?
```

### `macAlgorithm`

```swift
public var macAlgorithm: MacAlgorithm?
```

### `signatureStruct`

```swift
public var signatureStruct : Data?
```

Structure according to https://tools.ietf.org/html/rfc8152#section-4.2
