//
//  SWONUnkeyedDecodingContainer.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

struct SWONUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey]
    var count: Int? { array.count }
    var isAtEnd: Bool { currentIndex >= array.count }
    var currentIndex: Int = 0
    
    private let decoder: SWONDecoding
    private let array: [SWONData]
    
    init(decoder: SWONDecoding, array: [SWONData]) {
        self.decoder = decoder
        self.codingPath = decoder.codingPath
        self.array = array
    }

    func ensureNotAtEnd<T>(_ type: T.Type) throws -> SWONData {
        if isAtEnd {
            throw DecodingError.valueNotFound(type, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Unkeyed container is at end."
            ))
        } else {
            return array[currentIndex]
        }
    }

    func expected<T>(typeName: String? = nil, _ type: T.Type, for value: SWONData) -> DecodingError {

        let name = typeName ?? _typeName(type, qualified: false)
        return DecodingError.typeMismatch(type, DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "Expected to decode \(name) but found \(value)"
        ))
    }

    mutating func decodeNil() throws -> Bool {
        let value = try ensureNotAtEnd(Any?.self)

        if case .nil = value {
            currentIndex += 1
            return true
        }
        return false
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        let value = try ensureNotAtEnd(type)

        guard case .bool(let value) = value else {
            throw expected(type, for: value)
        }
        
        currentIndex += 1
        return value
    }
    
    mutating func decode(_ type: String.Type) throws -> String {
        let value = try ensureNotAtEnd(type)

        guard case .string(let value) = array[currentIndex] else {
            throw expected(type, for: value)
        }
        
        currentIndex += 1
        return value
    }

    mutating func decode<T: BinaryFloatingPoint>(type: T.Type) throws -> T {
        let value = try ensureNotAtEnd(type)

        switch value {
        case .float(let double):
            currentIndex += 1
            return T.init(double)
        case .integer(let int):
            currentIndex += 1
            return T.init(int)
        default:
            throw expected(type, for: value)
        }
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        try decode(type: type)
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        try decode(type: type)
    }

    mutating func decode<T: BinaryInteger>(type: T.Type) throws -> T {
        let value = try ensureNotAtEnd(Any?.self)

        guard case .integer(let value) = value else {
            throw expected(type, for: value)
        }

        currentIndex += 1
        return T.init(value)
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        try decode(type: type)
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        try decode(type: type)
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        try decode(type: type)
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        try decode(type: type)
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        try decode(type: type)
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        try decode(type: type)
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        try decode(type: type)
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        try decode(type: type)
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        try decode(type: type)
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        try decode(type: type)
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let value = try ensureNotAtEnd(type)

        currentIndex += 1
        
        let container = SWONKeyedDecodingContainer<NestedKey>(decoder: decoder, data: value)
        return KeyedDecodingContainer(container)
    }
    
    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let value = try ensureNotAtEnd(UnkeyedDecodingContainer.self)

        guard case .array(let value) = value else {
            throw expected(typeName: "array", UnkeyedDecodingContainer.self, for: value)
        }
        
        currentIndex += 1
        return SWONUnkeyedDecodingContainer(decoder: decoder, array: value)
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        switch type {
        case is Bool.Type:
            return try decode(Bool.self) as! T
        case is String.Type:
            return try decode(String.self) as! T
        case is Double.Type:
            return try decode(Double.self) as! T
        case is Double.Type:
            return try decode(Float.self) as! T
        case is Int.Type:
            return try decode(Int.self) as! T
        case is Int8.Type:
            return try decode(Int8.self) as! T
        case is Int16.Type:
            return try decode(Int16.self) as! T
        case is Int32.Type:
            return try decode(Int32.self) as! T
        case is Int64.Type:
            return try decode(Int64.self) as! T
        case is UInt.Type:
            return try decode(UInt.self) as! T
        case is UInt8.Type:
            return try decode(UInt8.self) as! T
        case is UInt16.Type:
            return try decode(UInt16.self) as! T
        case is UInt32.Type:
            return try decode(UInt32.self) as! T
        case is UInt64.Type:
            return try decode(UInt64.self) as! T
        default:
            let value = try ensureNotAtEnd(type)
            currentIndex += 1
            let decoder = SWONDecoding(data: value)
            decoder.codingPath = codingPath
            return try T(from: decoder)
        }
    }

    mutating func superDecoder() throws -> Decoder {
        let value = try ensureNotAtEnd(Decoder.self)
        currentIndex += 1
        return SWONDecoding(data: value)
    }
}
