**STRUCT**

# `DrivingPrivilege`

**Contents**

- [Properties](#properties)
  - `vehicleCategoryCode`
  - `issueDate`
  - `expiryDate`
  - `codes`

```swift
struct DrivingPrivilege: Codable
```

The categories of vehicles/restrictions/conditions contain information describing the driving privileges of the mDL holder

## Properties
### `vehicleCategoryCode`

```swift
let vehicleCategoryCode: String
```

Vehicle category code as per ISO/IEC 18013-1

### `issueDate`

```swift
let issueDate: String?
```

Date of issue encoded as full-date

### `expiryDate`

```swift
let expiryDate: String?
```

Date of expiry encoded as full-date

### `codes`

```swift
let codes: [DrivingPrivilegeCode]?
```

Array of code info
