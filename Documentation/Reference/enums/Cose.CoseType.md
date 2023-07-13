**ENUM**

# `Cose.CoseType`

**Contents**

- [Cases](#cases)
  - `sign1`
  - `mac0`
- [Methods](#methods)
  - `from(data:)`

```swift
public enum CoseType : String
```

COSE Message Identification

## Cases
### `sign1`

```swift
case sign1 = "Signature1"
```

COSE Single Signer Data Object
Only one signature is applied on the message payload

### `mac0`

```swift
case mac0 = "MAC0"
```

## Methods
### `from(data:)`

```swift
static func from(data: Data) -> CoseType?
```

Idenntifies Cose Message Type from input data
