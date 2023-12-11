**EXTENSION**

# `CoseKeyPrivate`
```swift
extension CoseKeyPrivate
```

## Methods
### `init(crv:)`

```swift
public init(crv: ECCurveType)
```

### `init(privateKeyx963Data:crv:)`

```swift
public init(privateKeyx963Data: Data, crv: ECCurveType = .p256)
```

### `init(publicKeyx963Data:secureEnclaveData:)`

```swift
public init(publicKeyx963Data: Data, secureEnclaveData: Data)
```

### `init(base64:)`

```swift
public init?(base64: String)
```

### `init(x:y:d:crv:)`

```swift
public init(x: [UInt8], y: [UInt8], d: [UInt8], crv: ECCurveType = .p256)
```

Create a COSE_Key from Elliptic Curve paramters of the private key.
- Parameters:
  - x: /// value of x-coordinate
  - y: /// value of y-coordinate
  - d: /// value of x-coordinate
  - crv: /// EC identifier

#### Parameters

| Name | Description |
| ---- | ----------- |
| x | /// value of x-coordinate |
| y | /// value of y-coordinate |
| d | /// value of x-coordinate |
| crv | /// EC identifier |

### `getx963Representation()`

```swift
public func getx963Representation() -> Data
```

An ANSI x9.63 representation of the private key.
