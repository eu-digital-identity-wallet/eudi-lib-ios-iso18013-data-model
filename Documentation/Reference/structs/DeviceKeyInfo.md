**STRUCT**

# `DeviceKeyInfo`

**Contents**

- [Properties](#properties)
  - `deviceKey`
  - `keyAuthorizations`
  - `keyInfo`
- [Methods](#methods)
  - `init(deviceKey:)`

```swift
public struct DeviceKeyInfo
```

mdoc authentication public key and information related to this key.

## Properties
### `deviceKey`

```swift
public let deviceKey: CoseKey
```

### `keyAuthorizations`

```swift
let keyAuthorizations: KeyAuthorizations?
```

### `keyInfo`

```swift
let keyInfo: CBOR?
```

## Methods
### `init(deviceKey:)`

```swift
public init(deviceKey: CoseKey)
```
