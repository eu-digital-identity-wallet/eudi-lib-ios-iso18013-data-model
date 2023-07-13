**STRUCT**

# `DeviceEngagement`

**Contents**

- [Properties](#properties)
  - `versionImpl`
  - `version`
  - `security`
  - `deviceRetrievalMethods`
  - `serverRetrievalOptions`
  - `d`
  - `privateKey`
- [Methods](#methods)
  - `setD(d:)`
  - `init(isBleServer:crv:)`
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
### `versionImpl`

```swift
static let versionImpl: String = "1.0"
```

### `version`

```swift
var version: String = Self.versionImpl
```

### `security`

```swift
let security: Security
```

### `deviceRetrievalMethods`

```swift
var deviceRetrievalMethods: [DeviceRetrievalMethod]? = nil
```

### `serverRetrievalOptions`

```swift
var serverRetrievalOptions: ServerRetrievalOptions? = nil
```

### `d`

```swift
var d: [UInt8]?
```

### `privateKey`

```swift
public var privateKey: CoseKeyPrivate?
```

## Methods
### `setD(d:)`

```swift
mutating func setD(d: [UInt8])
```

### `init(isBleServer:crv:)`

```swift
public init(isBleServer: Bool?, crv: ECCurveType = .p256)
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
