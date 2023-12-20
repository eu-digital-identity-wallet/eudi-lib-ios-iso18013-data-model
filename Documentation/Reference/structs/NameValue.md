**STRUCT**

# `NameValue`

**Contents**

- [Properties](#properties)
  - `ns`
  - `name`
  - `value`
  - `mdocDataType`
  - `order`
  - `children`
  - `description`
- [Methods](#methods)
  - `init(name:value:ns:mdocDataType:order:children:)`
  - `add(child:)`

```swift
public struct NameValue: Equatable, CustomStringConvertible
```

## Properties
### `ns`

```swift
public let ns: String?
```

### `name`

```swift
public let name: String
```

### `value`

```swift
public var value: String
```

### `mdocDataType`

```swift
public var mdocDataType: MdocDataType?
```

### `order`

```swift
public var order: Int = 0
```

### `children`

```swift
public var children: [NameValue]?
```

### `description`

```swift
public var description: String
```

## Methods
### `init(name:value:ns:mdocDataType:order:children:)`

```swift
public init(name: String, value: String, ns: String? = nil, mdocDataType: MdocDataType? = nil, order: Int = 0, children: [NameValue]? = nil)
```

### `add(child:)`

```swift
public mutating func add(child: NameValue)
```
