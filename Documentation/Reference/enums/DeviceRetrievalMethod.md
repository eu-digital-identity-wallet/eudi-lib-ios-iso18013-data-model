**ENUM**

# `DeviceRetrievalMethod`

**Contents**

- [Cases](#cases)
  - `qr`
  - `nfc(maxLenCommand:maxLenResponse:)`
  - `ble(isBleServer:uuid:)`

```swift
public enum DeviceRetrievalMethod: Equatable
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
