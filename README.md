# SWON
### Swift Object Notation

This is a proof of concept for Swift Object Notation (`.swon`), a data interchange format similar to JSON, except with Swift syntax.

> SomeFile.swon
```swift
[
    "hello": "world",
    "this": ["is", "SWON"],
    "its": [
        "aNewEncodingFormat": ["that", "uses"],
        "swift": ["as", "the", "interchange", "format"]
    ],
    "productionReady": false,
    "support": nil,
    "bugs": 1_000_000
]
```

## Why?

This is not a serious project. Much of it is Codable boilerplate and a very simple and inefficient parser built on top of [SwiftSyntax](https://github.com/swiftlang/swift-syntax).

## Usage

SWON vends `SWONEncoder` and `SWONDecoder` classes, similar to `JSONEncoder` and `JSONDecoder`. It's intended to work as closely to JSON Codable as possible, without many of the configuration features and niceties.

## Author

Harlan Haskins ([harlan@harlanhaskins.com](mailto:harlan@harlanhaskins.com))

