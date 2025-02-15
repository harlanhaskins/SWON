//
//  SWONKeyedDecodingContainer.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

struct SWONKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    var codingPath: [CodingKey]
    var allKeys: [K]

    private let decoder: SWONDecoding
    private let data: [String: SWONData]

    init(decoder: SWONDecoding, data: SWONData) {
        self.decoder = decoder
        self.codingPath = decoder.codingPath

        switch data {
        case .dictionary(let dict):
            self.data = dict
            self.allKeys = dict.keys.compactMap { K(stringValue: $0) }
        default:
            self.data = [:]
            self.allKeys = []
        }
    }

    func contains(_ key: K) -> Bool {
        return data[key.stringValue] != nil
    }

    func retrieve(_ key: K) throws -> SWONData {
        guard let value = data[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "No value associated with key \(key.stringValue)"
            ))
        }
        return value
    }

    func expected<T>(typeName: String? = nil, _ type: T.Type, for value: SWONData) -> DecodingError {

        let name = typeName ?? _typeName(type, qualified: false)
        return DecodingError.typeMismatch(type, DecodingError.Context(
            codingPath: codingPath,
            debugDescription: "Expected to decode \(name) but found \(value)"
        ))
    }

    func decodeNil(forKey key: K) throws -> Bool {
        return try retrieve(key) == .nil
    }

    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        let value = try retrieve(key)
        guard case .bool(let bool) = value else {
            throw expected(type, for: value)
        }
        return bool
    }

    func decode(_ type: String.Type, forKey key: K) throws -> String {
        let value = try retrieve(key)
        guard case .string(let string) = value else {
            throw expected(type, for: value)
        }
        return string
    }

    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        let value = try retrieve(key)
        switch value {
        case .float(let double):
            return double
        case .integer(let int):
            return Double(int)
        default:
            throw expected(type, for: value)
        }
    }

    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        let value = try retrieve(key)
        switch value {
        case .float(let value):
            return Float(value)
        case .integer(let int):
            return Float(int)
        default:
            throw expected(type, for: value)
        }
    }

    func decode<T: BinaryInteger>(type: T.Type, forKey key: K) throws -> T {
        let value = try retrieve(key)
        switch value {
        case .integer(let int):
            return T.init(int)
        default:
            throw expected(type, for: value)
        }
    }

    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        try decode(type: type, forKey: key)
    }

    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        try decode(type: type, forKey: key)
    }

    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        try decode(type: type, forKey: key)
    }

    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        try decode(type: type, forKey: key)
    }

    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        try decode(type: type, forKey: key)
    }

    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        try decode(type: type, forKey: key)
    }

    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        try decode(type: type, forKey: key)
    }

    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        try decode(type: type, forKey: key)
    }

    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        try decode(type: type, forKey: key)
    }

    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        try decode(type: type, forKey: key)
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: K) throws -> T {
        try decoder.withCurrentKey(key) {
            let value = try retrieve(key)
            let nestedDecoder = SWONDecoding(data: value)
            nestedDecoder.codingPath = decoder.codingPath

            return try T(from: nestedDecoder)
        }
    }

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type,
        forKey key: K
    ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
        try decoder.withCurrentKey(key) {
            let value = try retrieve(key)
            let container = SWONKeyedDecodingContainer<NestedKey>(decoder: decoder, data: value)
            return KeyedDecodingContainer(container)
        }
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        try decoder.withCurrentKey(key) {
            let value = try retrieve(key)

            guard case .array(let array) = value else {
                throw expected(typeName: "array", [Any].self, for: value)
            }

            return SWONUnkeyedDecodingContainer(decoder: decoder, array: array)
        }
    }

    func superDecoder() throws -> Decoder {
        return decoder
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        try decoder.withCurrentKey(key) {
            let value = try retrieve(key)
            return SWONDecoding(data: value)
        }
    }
}
