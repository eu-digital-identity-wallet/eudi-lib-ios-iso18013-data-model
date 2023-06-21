**STRUCT**

# `Document`

**Contents**

- [Properties](#properties)
  - `docType`
  - `issuerSigned`
  - `deviceSigned`
  - `errors`

```swift
struct Document
```

Contains a returned cocument. The document type of the returned document is indicated by the docType element.

## Properties
### `docType`

```swift
let docType: DocType
```

### `issuerSigned`

```swift
let issuerSigned: IssuerSigned
```

### `deviceSigned`

```swift
let deviceSigned: DeviceSigned
```

### `errors`

```swift
let errors: Errors?
```

error codes for data elements that are not returned
