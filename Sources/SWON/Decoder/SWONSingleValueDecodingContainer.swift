//
//  SWONSingleValueDecodingContainer.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

struct SWONSingleValueDecodingContainer: SingleValueDecodingContainer {
    var codingPath: [CodingKey]
    
    private let decoder: SWONDecoding
    private let data: SWONData
    
    init(decoder: SWONDecoding, data: SWONData) {
        self.decoder = decoder
        self.codingPath = decoder.codingPath
        self.data = data
    }
    
    func decodeNil() -> Bool {
        if case .nil = data {
            return true
        }
        return false
    }

    func expected<T>(typeName: String? = nil, _ type: T.Type, for value: SWONData) -> DecodingError {

        let name = typeName ?? _typeName(type, qualified: false)
        return DecodingError.typeMismatch(type, DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "Expected to decode \(name) but found \(value)"
        ))
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard case .bool(let value) = data else {
            throw expected(type, for: data)
        }
        return value
    }
    
    func decode(_ type: String.Type) throws -> String {
        guard case .string(let value) = data else {
            throw expected(type, for: data)
        }
        return value
    }

    func decode<T: BinaryFloatingPoint>(type: T.Type) throws -> T {
        switch data {
        case .float(let double):
            return T.init(double)
        case .integer(let int):
            return T.init(int)
        default:
            throw expected(type, for: data)
        }
    }

    func decode(_ type: Double.Type) throws -> Double {
        try decode(type: type)
    }

    func decode(_ type: Float.Type) throws -> Float {
        try decode(type: type)
    }

    func decode<T: BinaryInteger>(type: T.Type) throws -> T {
        guard case .integer(let value) = data else {
            throw expected(type, for: data)
        }
        return T.init(value)
    }

    func decode(_ type: Int.Type) throws -> Int {
        try decode(type: type)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try decode(type: type)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try decode(type: type)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try decode(type: type)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try decode(type: type)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try decode(type: type)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try decode(type: type)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try decode(type: type)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try decode(type: type)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try decode(type: type)
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        // Handle standard types directly to avoid recursion
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
            // For custom types or collections, create a new decoder
            let decoder = SWONDecoding(data: data)
            decoder.codingPath = codingPath
            return try T(from: decoder)
        }
    }
}
