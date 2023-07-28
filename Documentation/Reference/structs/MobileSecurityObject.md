**STRUCT**

# `MobileSecurityObject`

**Contents**

- [Properties](#properties)
  - `version`
  - `defaultVersion`
  - `digestAlgorithm`
  - `defaultDigestAlgorithmKind`
  - `valueDigests`
  - `deviceKeyInfo`
  - `docType`
  - `validityInfo`
- [Methods](#methods)
  - `init(version:digestAlgorithm:valueDigests:deviceKey:docType:validityInfo:)`

```swift
public struct MobileSecurityObject
```

Mobile security object (MSO)

## Properties
### `version`

```swift
public let version: String
```

### `defaultVersion`

```swift
public static let defaultVersion = "1.0"
```

### `digestAlgorithm`

```swift
public let digestAlgorithm: String
```

Message digest algorithm used

### `defaultDigestAlgorithmKind`

```swift
public static let defaultDigestAlgorithmKind = DigestAlgorithmKind.SHA256
```

### `valueDigests`

```swift
public let valueDigests: ValueDigests
```

Value digests

### `deviceKeyInfo`

```swift
let deviceKeyInfo: DeviceKeyInfo
```

device key info

### `docType`

```swift
public let docType: DocType
```

docType  as used in Documents

### `validityInfo`

```swift
public let validityInfo: ValidityInfo
```

## Methods
### `init(version:digestAlgorithm:valueDigests:deviceKey:docType:validityInfo:)`

```swift
public init(version: String, digestAlgorithm: String, valueDigests: ValueDigests, deviceKey: CoseKey, docType: DocType, validityInfo: ValidityInfo)
```
