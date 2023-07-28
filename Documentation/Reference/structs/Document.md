**STRUCT**

# `Document`

**Contents**

- [Properties](#properties)
  - `docType`
  - `issuerSigned`
  - `deviceSigned`
  - `errors`
- [Methods](#methods)
  - `init(docType:issuerSigned:deviceSigned:errors:)`

```swift
public struct Document
```

Contains a returned cocument. The document type of the returned document is indicated by the docType element.

## Properties
### `docType`

```swift
public let docType: DocType
```

### `issuerSigned`

```swift
public let issuerSigned: IssuerSigned
```

### `deviceSigned`

```swift
public let deviceSigned: DeviceSigned?
```

### `errors`

```swift
public let errors: Errors?
```

error codes for data elements that are not returned

## Methods
### `init(docType:issuerSigned:deviceSigned:errors:)`

```swift
public init(docType: DocType, issuerSigned: IssuerSigned, deviceSigned: DeviceSigned? = nil, errors: Errors? = nil)
```
