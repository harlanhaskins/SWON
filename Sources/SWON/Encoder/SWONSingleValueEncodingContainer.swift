//
//  SWONSingleValueEncodingContainer.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

struct SWONSingleValueEncodingContainer: SingleValueEncodingContainer {
    var codingPath: [CodingKey] {
        encoder.codingPath
    }
    let encoder: SWONEncoding

    init(encoder: SWONEncoding) {
        self.encoder = encoder
    }

    private mutating func encodeInteger<T: BinaryInteger>(_ value: T) throws {
        encoder.storage = .integer(Int64(value))
    }

    mutating func encodeNil() throws {
        encoder.storage = .nil
    }

    mutating func encode(_ value: Bool) throws {
        encoder.storage = .bool(value)
    }

    mutating func encode(_ value: String) throws {
        encoder.storage = .string(value)
    }

    mutating func encode(_ value: Double) throws {
        encoder.storage = .float(value)
    }

    mutating func encode(_ value: Float) throws {
        encoder.storage = .float(Double(value))
    }

    mutating func encode<I: BinaryInteger>(value: I) throws {
        encoder.storage = .integer(Int64(value))
    }

    mutating func encode(_ value: Int) throws {
        try encode(value: value)
    }

    mutating func encode(_ value: Int8) throws {
        try encode(value: value)
    }

    mutating func encode(_ value: Int16) throws {
        try encode(value: value)
    }

    mutating func encode(_ value: Int32) throws {
        try encode(value: value)
    }

    mutating func encode(_ value: Int64) throws {
        try encode(value: value)
    }

    mutating func encode(_ value: UInt) throws {
        try encode(value: value)
    }

    mutating func encode(_ value: UInt8) throws {
        try encode(value: value)
    }

    mutating func encode(_ value: UInt16) throws {
        try encode(value: value)
    }

    mutating func encode(_ value: UInt32) throws {
        try encode(value: value)
    }

    mutating func encode(_ value: UInt64) throws {
        try encode(value: value)
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
        switch value {
        case let value as Bool:
            encoder.storage = .bool(value)
        case let value as String:
            encoder.storage = .string(value)
        case let value as Double:
            encoder.storage = .float(value)
        case let value as Float:
            encoder.storage = .float(Double(value))
        case let value as Int:
            encoder.storage = .integer(Int64(value))
        case let value as Int8:
            encoder.storage = .integer(Int64(value))
        case let value as Int16:
            encoder.storage = .integer(Int64(value))
        case let value as Int32:
            encoder.storage = .integer(Int64(value))
        case let value as Int64:
            encoder.storage = .integer(value)
        case let value as UInt:
            encoder.storage = .integer(Int64(value))
        case let value as UInt8:
            encoder.storage = .integer(Int64(value))
        case let value as UInt16:
            encoder.storage = .integer(Int64(value))
        case let value as UInt32:
            encoder.storage = .integer(Int64(value))
        case let value as UInt64:
            encoder.storage = .integer(Int64(value))
        default:
            let nestedEncoder = SWONEncoding(codingKey: nil, parent: encoder)
            try value.encode(to: nestedEncoder)
            encoder.storage = nestedEncoder.storage
        }
    }
}
