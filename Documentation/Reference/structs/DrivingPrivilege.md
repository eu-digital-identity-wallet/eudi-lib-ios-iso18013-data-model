**STRUCT**

# `DrivingPrivilege`

**Contents**

- [Properties](#properties)
  - `vehicleCategoryCode`
  - `issueDate`
  - `expiryDate`
  - `codes`

```swift
public struct DrivingPrivilege: Codable
```

The categories of vehicles/restrictions/conditions contain information describing the driving privileges of the mDL holder

## Properties
### `vehicleCategoryCode`

```swift
public let vehicleCategoryCode: String
```

Vehicle category code as per ISO/IEC 18013-1

### `issueDate`

```swift
public let issueDate: String?
```

Date of issue encoded as full-date

### `expiryDate`

```swift
public let expiryDate: String?
```

Date of expiry encoded as full-date

### `codes`

```swift
public let codes: [DrivingPrivilegeCode]?
```

Array of code info
