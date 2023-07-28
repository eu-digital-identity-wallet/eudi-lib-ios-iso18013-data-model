**STRUCT**

# `IsoMdlModel`

**Contents**

- [Properties](#properties)
  - `response`
  - `exp`
  - `iat`
  - `familyName`
  - `givenName`
  - `birthDate`
  - `birthPlace`
  - `issueDate`
  - `expiryDate`
  - `issuingCountry`
  - `issuingAuthority`
  - `documentNumber`
  - `administrativeNumber`
  - `drivingPrivileges`
  - `nationality`
  - `eyeColour`
  - `hairColour`
  - `height`
  - `weight`
  - `sex`
  - `residentAddress`
  - `residentCountry`
  - `residentCity`
  - `residentState`
  - `residentPostalCode`
  - `ageInYears`
  - `ageOverXX`
  - `displayStrings`
  - `ageBirthYear`
  - `portrait`
  - `unDistinguishingSign`
  - `issuingJurisdiction`
  - `portraitCaptureDate`
  - `familyNameNationalCharacter`
  - `givenNameNationalCharacter`
  - `signatureUsualMark`
  - `biometricTemplateFace`
  - `biometricTemplateSignatureSign`
  - `webapiInfo`
  - `oidcInfo`
  - `namespace`
  - `docType`
  - `title`
  - `mandatoryKeys`
  - `isoMandatoryKeys`

```swift
public struct IsoMdlModel: Decodable, MdocDecodable
```

## Properties
### `response`

```swift
public var response: DeviceResponse?
```

### `exp`

```swift
let exp: UInt64?
```

### `iat`

```swift
let iat: UInt64?
```

### `familyName`

```swift
public let familyName: String?
```

### `givenName`

```swift
public let givenName: String?
```

### `birthDate`

```swift
public let birthDate: String?
```

### `birthPlace`

```swift
public let birthPlace: String?
```

### `issueDate`

```swift
public let issueDate: String?
```

### `expiryDate`

```swift
public let expiryDate: String?
```

### `issuingCountry`

```swift
public let issuingCountry: String?
```

### `issuingAuthority`

```swift
public let issuingAuthority: String?
```

### `documentNumber`

```swift
public let documentNumber: String?
```

### `administrativeNumber`

```swift
public let administrativeNumber: String?
```

### `drivingPrivileges`

```swift
let drivingPrivileges: DrivingPrivileges?
```

### `nationality`

```swift
public let nationality: String?
```

### `eyeColour`

```swift
public let eyeColour: String?
```

### `hairColour`

```swift
public let hairColour: String?
```

### `height`

```swift
public let height: UInt64?
```

### `weight`

```swift
public let weight: UInt64?
```

### `sex`

```swift
public let sex: UInt64?
```

### `residentAddress`

```swift
public let residentAddress: String?
```

### `residentCountry`

```swift
public let residentCountry: String?
```

### `residentCity`

```swift
public let residentCity: String?
```

### `residentState`

```swift
public let residentState: String?
```

### `residentPostalCode`

```swift
public let residentPostalCode: String?
```

### `ageInYears`

```swift
public let ageInYears: UInt64?
```

### `ageOverXX`

```swift
public var ageOverXX = [Int: Bool]()
```

### `displayStrings`

```swift
public var displayStrings = [NameValue]()
```

### `ageBirthYear`

```swift
public let ageBirthYear: UInt64?
```

### `portrait`

```swift
public let portrait: [UInt8]?
```

### `unDistinguishingSign`

```swift
public let unDistinguishingSign: String?
```

### `issuingJurisdiction`

```swift
public let issuingJurisdiction: String?
```

### `portraitCaptureDate`

```swift
public let portraitCaptureDate: String?
```

### `familyNameNationalCharacter`

```swift
public let familyNameNationalCharacter: String?
```

### `givenNameNationalCharacter`

```swift
public let givenNameNationalCharacter: String?
```

### `signatureUsualMark`

```swift
public let signatureUsualMark: [UInt8]?
```

### `biometricTemplateFace`

```swift
public let biometricTemplateFace: String?
```

### `biometricTemplateSignatureSign`

```swift
public let biometricTemplateSignatureSign: String?
```

### `webapiInfo`

```swift
let webapiInfo: ServerRetrievalOption?
```

### `oidcInfo`

```swift
let oidcInfo: ServerRetrievalOption?
```

### `namespace`

```swift
public static var namespace: String
```

### `docType`

```swift
public static var docType: String
```

### `title`

```swift
public static let title = String("mdl_doctype_name")
```

### `mandatoryKeys`

```swift
public static var mandatoryKeys: [String]
```

### `isoMandatoryKeys`

```swift
public static var isoMandatoryKeys: [CodingKeys]
```
