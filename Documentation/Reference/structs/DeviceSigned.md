**STRUCT**

# `DeviceSigned`

**Contents**

- [Properties](#properties)
  - `nameSpaces`
  - `nameSpacesRawData`
  - `deviceAuth`
- [Methods](#methods)
  - `init(deviceAuth:)`

```swift
public struct DeviceSigned
```

Contains the mdoc authentication structure and the data elements protected by mdoc authentication

## Properties
### `nameSpaces`

```swift
let nameSpaces: DeviceNameSpaces
```

### `nameSpacesRawData`

```swift
let nameSpacesRawData: [UInt8]
```

### `deviceAuth`

```swift
let deviceAuth: DeviceAuth
```

## Methods
### `init(deviceAuth:)`

```swift
public init(deviceAuth: DeviceAuth)
```
