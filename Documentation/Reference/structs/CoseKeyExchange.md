**STRUCT**

# `CoseKeyExchange`

**Contents**

- [Properties](#properties)
  - `publicKey`
  - `privateKey`
- [Methods](#methods)
  - `init(publicKey:privateKey:)`

```swift
public struct CoseKeyExchange
```

A COSE_Key exchange pair

## Properties
### `publicKey`

```swift
public let publicKey: CoseKey
```

### `privateKey`

```swift
public let privateKey: CoseKeyPrivate
```

## Methods
### `init(publicKey:privateKey:)`

```swift
public init(publicKey: CoseKey, privateKey: CoseKeyPrivate)
```
