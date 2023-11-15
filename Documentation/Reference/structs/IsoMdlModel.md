**STRUCT**

# `IsoMdlModel`

**Contents**

- [Properties](#properties)
  - `docType`
  - `nameSpaces`
  - `title`
  - `isoDocType`
  - `isoNamespace`
  - `response`
  - `devicePrivateKey`
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
  - `mandatoryKeys`
  - `isoMandatoryKeys`

```swift
public struct IsoMdlModel: Decodable, MdocDecodable
```

## Properties
### `docType`

```swift
public var docType: String = Self.isoDocType
```

### `nameSpaces`

```swift
public var nameSpaces: [NameSpace]?
```

### `title`

```swift
public var title = String("mdl_doctype_name")
```

### `isoDocType`

```swift
public static var isoDocType: String
```

### `isoNamespace`

```swift
public static var isoNamespace: String
```

### `response`

```swift
public var response: DeviceResponse?
```

### `devicePrivateKey`

```swift
public var devicePrivateKey: CoseKeyPrivate?
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
public let drivingPrivileges: DrivingPrivileges?
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

### `mandatoryKeys`

```swift
public static var mandatoryKeys: [String]
```

### `isoMandatoryKeys`

```swift
public static var isoMandatoryKeys: [CodingKeys]
```
