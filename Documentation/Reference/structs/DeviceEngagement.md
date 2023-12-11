**STRUCT**

# `DeviceEngagement`

**Contents**

- [Properties](#properties)
  - `originInfos`
  - `deviceRetrievalMethods`
  - `serverRetrievalOptions`
  - `qrCoded`
  - `privateKey`
  - `isBleServer`
  - `ble_uuid`
- [Methods](#methods)
  - `init(isBleServer:crv:rfus:)`
  - `init(data:)`

```swift
public struct DeviceEngagement
```

Device engagement information

in mdoc holder generate an mdoc ephemeral private key
```swift
let de = DeviceEngagement(isBleServer: isBleServer, crv: .p256)
qrCodeImage = de.getQrCodeImage()
```

In mdoc reader decode device engagement CBOR bytes (e.g. from QR code)
```swift
let de = DeviceEngagement(data: bytes)
```

## Properties
### `originInfos`

```swift
public var originInfos: [OriginInfoWebsite]? = nil
```

### `deviceRetrievalMethods`

```swift
public var deviceRetrievalMethods: [DeviceRetrievalMethod]? = nil
```

### `serverRetrievalOptions`

```swift
public var serverRetrievalOptions: ServerRetrievalOptions? = nil
```

### `qrCoded`

```swift
public var qrCoded: [UInt8]?
```

### `privateKey`

```swift
public var privateKey: CoseKeyPrivate?
```

### `isBleServer`

```swift
public var isBleServer: Bool?
```

### `ble_uuid`

```swift
public var ble_uuid: String?
```

## Methods
### `init(isBleServer:crv:rfus:)`

```swift
public init(isBleServer: Bool?, crv: ECCurveType = .p256, rfus: [String]? = nil)
```

Generate device engagement
- Parameters
   - isBleServer: true for BLE mdoc peripheral server mode, false for BLE mdoc central client mode
   - crv: The EC curve type used in the mdoc ephemeral private key

### `init(data:)`

```swift
public init?(data: [UInt8])
```

initialize from cbor data
