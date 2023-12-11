**STRUCT**

# `NameValue`

**Contents**

- [Properties](#properties)
  - `ns`
  - `name`
  - `value`
  - `order`
  - `children`
  - `description`
- [Methods](#methods)
  - `init(name:value:ns:order:children:)`
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
### `init(name:value:ns:order:children:)`

```swift
public init(name: String, value: String, ns: String? = nil, order: Int = 0, children: [NameValue]? = nil)
```

### `add(child:)`

```swift
public mutating func add(child: NameValue)
```
