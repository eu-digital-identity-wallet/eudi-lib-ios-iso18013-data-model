# EUDI Wallet Data Model library ISO/IEC 18013-5 for iOS

:heavy_exclamation_mark: **Important!** Before you proceed, please read
the [EUDI Wallet Reference Implementation project description](https://github.com/eu-digital-identity-wallet/.github/blob/main/profile/reference-implementation.md)

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

Device retrieval [mdoc request](Documentation/Reference/structs/DeviceRequest.md) structure
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

Device retrieval [mdoc response](Documentation/Reference/structs/DeviceResponse.md). It is CBOR encoded

In mdoc reader initialize from CBOR data received from holder (data exchange)
In mdoc holder initialize from CBOR data received from server (registration)

```swift
let dr = DeviceResponse(data: bytes)
```

The device response has the following structure:

Data = {
 "documents" : [+Document] 
}

[Document](Documentation/Reference/structs/Document.md) = {
 "docType" : DocType, 
 "issuerSigned" : IssuerSigned 
}

[IssuerSigned](Documentation/Reference/structs/IssuerSigned.md) = {
 "nameSpaces" : IssuerNameSpaces, 
}

[IssuerNameSpaces](Documentation/Reference/structs/IssuerNameSpaces.md) = { 
 + NameSpace => [ + IssuerSignedItemBytes ]
}

[IssuerSignedItem](Documentation/Reference/structs/IssuerSignedItem.md) = {
 "digestID" : uint, 
 "random" : bstr, 
 "elementIdentifier" : DataElementIdentifier, 
 "elementValue" : DataElementValue 
}

## Dependencies (to other libs)

* A CBOR implementation for Swift [SwiftCBOR](https://github.com/niscy-eudiw/SwiftCBOR)
* A Logging API for Swift: [swift-log](https://github.com/apple/swift-log)
* Commonly used data structures for Swift [swift-collections](https://github.com/apple/swift-collections)

## Reference
Detailed documentation is provided [here](Documentation/Reference/README.md) 

### Disclaimer
The released software is a initial development release version: 
-  The initial development release is an early endeavor reflecting the efforts of a short timeboxed period, and by no means can be considered as the final product.  
-  The initial development release may be changed substantially over time, might introduce new features but also may change or remove existing ones, potentially breaking compatibility with your existing code.
-  The initial development release is limited in functional scope.
-  The initial development release may contain errors or design flaws and other problems that could cause system or other failures and data loss.
-  The initial development release has reduced security, privacy, availability, and reliability standards relative to future releases. This could make the software slower, less reliable, or more vulnerable to attacks than mature software.
-  The initial development release is not yet comprehensively documented. 
-  Users of the software must perform sufficient engineering and additional testing in order to properly evaluate their application and determine whether any of the open-sourced components is suitable for use in that application.
-  We strongly recommend to not put this version of the software into production use.
-  Only the latest version of the software will be supported

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
