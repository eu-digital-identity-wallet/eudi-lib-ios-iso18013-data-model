**STRUCT**

# `ValidityInfo`

**Contents**

- [Properties](#properties)
  - `signed`
  - `validFrom`
  - `validUntil`
  - `expectedUpdate`
- [Methods](#methods)
  - `init(signed:validFrom:validUntil:expectedUpdate:)`

```swift
public struct ValidityInfo
```

The `ValidityInfo` structure contains information related to the validity of the MSO and its signature

## Properties
### `signed`

```swift
public let signed: String
```

### `validFrom`

```swift
public let validFrom: String
```

### `validUntil`

```swift
public let validUntil: String
```

### `expectedUpdate`

```swift
public let expectedUpdate: String?
```

## Methods
### `init(signed:validFrom:validUntil:expectedUpdate:)`

```swift
public init(signed: String, validFrom: String, validUntil: String, expectedUpdate: String? = nil)
```
