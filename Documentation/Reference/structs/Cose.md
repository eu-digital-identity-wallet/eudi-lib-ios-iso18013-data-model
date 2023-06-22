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
struct Cose
```

Struct which describes  a representation for cryptographic keys;  how to create and process signatures, message authentication codes, and  encryption using Concise Binary Object Representation (CBOR) or serialization.

## Properties
### `type`

```swift
let type: CoseType
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
let payload : CBOR
```

### `signature`

```swift
let signature : Data
```

### `verifyAlgorithm`

```swift
var verifyAlgorithm: VerifyAlgorithm?
```

### `macAlgorithm`

```swift
var macAlgorithm: MacAlgorithm?
```

### `keyId`

```swift
var keyId : Data?
```

### `signatureStruct`

```swift
var signatureStruct : Data?
```
