**ENUM**

# `DeviceRetrievalMethod`

**Contents**

- [Cases](#cases)
  - `qr`
  - `nfc(maxLenCommand:maxLenResponse:)`
  - `ble(isBleServer:uuid:)`
- [Properties](#properties)
  - `version`
  - `BASE_UUID_SUFFIX_SERVICE`
- [Methods](#methods)
  - `getRandomBleUuid()`

```swift
enum DeviceRetrievalMethod: Equatable
```

A `DeviceRetrievalMethod` holds two mandatory values (type and version). The first element defines the type and the second element the version for the transfer method.
Additionally, may contain extra info for each connection.

## Cases
### `qr`

```swift
case qr
```

### `nfc(maxLenCommand:maxLenResponse:)`

```swift
case nfc(maxLenCommand: UInt64, maxLenResponse: UInt64)
```

### `ble(isBleServer:uuid:)`

```swift
case ble(isBleServer: Bool, uuid: String)
```

## Properties
### `version`

```swift
static var version: UInt64
```

### `BASE_UUID_SUFFIX_SERVICE`

```swift
static let BASE_UUID_SUFFIX_SERVICE = "-0000-1000-8000-00805F9B34FB".replacingOccurrences(of: "-", with: "")
```

## Methods
### `getRandomBleUuid()`

```swift
static func getRandomBleUuid() -> String
```
