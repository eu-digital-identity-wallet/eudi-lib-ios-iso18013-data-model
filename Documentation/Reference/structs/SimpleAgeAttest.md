**STRUCT**

# `SimpleAgeAttest`

**Contents**

- [Properties](#properties)
  - `ageOverXX`
- [Methods](#methods)
  - `init(ageOver1:isOver1:ageOver2:isOver2:)`
  - `init(namespaces:)`

```swift
public struct SimpleAgeAttest: AgeAttesting
```

## Properties
### `ageOverXX`

```swift
public var ageOverXX = [Int: Bool]()
```

## Methods
### `init(ageOver1:isOver1:ageOver2:isOver2:)`

```swift
public init(ageOver1: Int, isOver1: Bool, ageOver2: Int, isOver2: Bool)
```

### `init(namespaces:)`

```swift
public init(namespaces: [NameSpace: [IssuerSignedItem]])
```
