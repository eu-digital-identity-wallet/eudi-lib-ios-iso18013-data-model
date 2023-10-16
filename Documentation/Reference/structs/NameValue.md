**STRUCT**

# `NameValue`

**Contents**

- [Properties](#properties)
  - `ns`
  - `name`
  - `value`
  - `order`
  - `description`
- [Methods](#methods)
  - `init(name:value:ns:order:)`

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

### `description`

```swift
public var description: String
```

## Methods
### `init(name:value:ns:order:)`

```swift
public init(name: String, value: String, ns: String? = nil, order: Int = 0)
```
