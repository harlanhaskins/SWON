//
//  SWONSingleValueEncodingContainer.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

struct SWONSingleValueEncodingContainer: SingleValueEncodingContainer {
    let codingPath: [CodingKey]
    let encoder: SWONEncoding

    init(encoder: SWONEncoding) {
        self.encoder = encoder
        self.codingPath = encoder.codingPath
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
            let nestedEncoder = SWONEncoding()
            nestedEncoder.codingPath = self.codingPath
            try value.encode(to: nestedEncoder)
            encoder.storage = nestedEncoder.storage
        }
    }
}
