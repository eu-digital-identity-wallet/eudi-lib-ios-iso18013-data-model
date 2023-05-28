# MdocDataModel18013
Implementation of the mDoc data model according to [ISO/IEC 18013-5](https://www.iso.org/standard/69084.html) standard
(0.1: Device engagement implemented )

## Device engagement
The `DeviceEngagement` structure contains information to perform device engagement.
At present, device engagement using QR code and data retrieval using Bluetooth low energy (BLE) are available.

### Initialization
To initialize a new instance of the `DeviceEngagement` structure, supply BLE mode and optionally EC Curve type.
You can then retrieve a QR code image, as the following code shows:
```swift
let de = DeviceEngagement(isBleServer: isBleServer, crv: .p256)
// get a UIKit image
let qrCodeImage = de.getQrCodeImage()
// to use in SwiftUI, use the Image(uiImage:) initializer
...
```
![Device engagement first demo](Sources/MdocDataModel18013/MdocDataModel18013.docc/Screenshots/Simulator Screenshot - DE.png)
