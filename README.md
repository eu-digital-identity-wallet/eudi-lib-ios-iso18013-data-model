[![Swift](https://github.com/eu-digital-identity-wallet/eudi-lib-ios-iso18013-data-model/actions/workflows/swift.yml/badge.svg?event=workflow_run)](https://github.com/eu-digital-identity-wallet/eudi-lib-ios-iso18013-data-model/actions/workflows/swift.yml)

# eudi-lib-ios-iso18013-data-model
Implementation of the mDoc data model according to [ISO/IEC 18013-5](https://www.iso.org/standard/69084.html) standard
(0.9.0)

## Overview
### `DeviceEngagement`
The `DeviceEngagement` structure contains information to perform device engagement.
At present, device engagement using QR code and data retrieval using Bluetooth low energy (BLE) are available.

#### Initialization
To initialize a new instance of the `DeviceEngagement` structure, supply BLE mode and optionally EC Curve type.
You can then retrieve a QR code image, as the following code shows:
```swift
let de = DeviceEngagement(isBleServer: isBleServer, crv: .p256)
// get a UIKit image
let qrCodeImage = de.getQrCodeImage()
// to use in SwiftUI, use the Image(uiImage:) initializer
...
```

### `DeviceRequest`

Device retrieval mdoc request structure
In mDoc holder initialize a ``DeviceRequest`` with incoming CBOR bytes (decoding)
```swift
let dr = DeviceRequest(data: bytes)
```
In mdoc reader initialize a ``DeviceRequest`` with desired elements to read 
```swift
let isoKeys: [IsoMdlModel.CodingKeys] = [.familyName, .documentNumber, .drivingPrivileges, .issueDate, .expiryDate, .portrait]
let dr3 = DeviceRequest(mdl: isoKeys, agesOver: [18,21], intentToRetain: true)
```
### `DeviceResponse`

Device retrieval mdoc response. It is CBOR encoded

In mdoc reader initialize from CBOR data received from holder (data exchange)
In mdoc holder initialize from CBOR data received from server (registration)

```swift
let dr = DeviceResponse(data: bytes)
```

## Reference
Detailed documentation is provided [here](Documentation/Reference/README.md) 

