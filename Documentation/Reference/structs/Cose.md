**STRUCT**

# `Cose`

**Contents**

- [Properties](#properties)
  - `type`
  - `protectedHeader`
  - `unprotectedHeader`
  - `payload`
  - `signature`
  - `verifyAlgorithm`
  - `macAlgorithm`
  - `keyId`
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

### `protectedHeader`

```swift
let protectedHeader : CoseHeader
```

### `unprotectedHeader`

```swift
let unprotectedHeader : CoseHeader?
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

### `keyId`

```swift
var keyId : Data?
```

### `signatureStruct`

```swift
public var signatureStruct : Data?
```
