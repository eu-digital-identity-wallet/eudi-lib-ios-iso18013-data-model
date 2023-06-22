**STRUCT**

# `RequestDataElements`

**Contents**

- [Properties](#properties)
  - `dataElements`
  - `elementIdentifiers`

```swift
struct RequestDataElements
```

Requested data elements identified by their data element identifier.

## Properties
### `dataElements`

```swift
let dataElements: [DataElementIdentifier: IntentToRetain]
```

IntentToRetain indicates whether the mdoc verifier intends to retain the received data element

### `elementIdentifiers`

```swift
var elementIdentifiers: [DataElementIdentifier]
```
