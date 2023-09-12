# EUDI Wallet Reference Implementation

:heavy_exclamation_mark: **Important!** Before you proceed, please read the [EUDI Wallet Reference Implementation project description](wiki/EUDI_Wallet_Reference_Implementation.md)

----

# eudi-lib-ios-iso18013-data-model

[![Swift](https://github.com/eu-digital-identity-wallet/eudi-lib-ios-iso18013-data-model/actions/workflows/swift.yml/badge.svg)](https://github.com/eu-digital-identity-wallet/eudi-lib-ios-iso18013-data-model/actions/workflows/swift.yml)
[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=eu-digital-identity-wallet_eudi-lib-ios-iso18013-data-model&metric=ncloc&token=b00a8ef181dca9772a601a2889bf78338ac9e0e9)](https://sonarcloud.io/summary/new_code?id=eu-digital-identity-wallet_eudi-lib-ios-iso18013-data-model)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=eu-digital-identity-wallet_eudi-lib-ios-iso18013-data-model&metric=duplicated_lines_density&token=b00a8ef181dca9772a601a2889bf78338ac9e0e9)](https://sonarcloud.io/summary/new_code?id=eu-digital-identity-wallet_eudi-lib-ios-iso18013-data-model)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=eu-digital-identity-wallet_eudi-lib-ios-iso18013-data-model&metric=reliability_rating&token=b00a8ef181dca9772a601a2889bf78338ac9e0e9)](https://sonarcloud.io/summary/new_code?id=eu-digital-identity-wallet_eudi-lib-ios-iso18013-data-model)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=eu-digital-identity-wallet_eudi-lib-ios-iso18013-data-model&metric=vulnerabilities&token=b00a8ef181dca9772a601a2889bf78338ac9e0e9)](https://sonarcloud.io/summary/new_code?id=eu-digital-identity-wallet_eudi-lib-ios-iso18013-data-model)

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

### License details

Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.