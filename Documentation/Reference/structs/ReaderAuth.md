**STRUCT**

# `ReaderAuth`

**Contents**

- [Properties](#properties)
  - `coseSign1`
  - `iaca`

```swift
struct ReaderAuth
```

Reader authentication structure encoded as Cose Sign1

## Properties
### `coseSign1`

```swift
let coseSign1: Cose
```

encoded data

### `iaca`

```swift
let iaca: SecCertificate
```

IACA certificate
