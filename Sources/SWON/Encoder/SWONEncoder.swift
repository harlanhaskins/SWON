//
//  SWONEncoder.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

import Foundation

public struct SWONEncoder {
    public var indentation: Int = 4
    public var prettyPrint: Bool = false
    public var sortKeys: Bool = false

    public init() {}

    @inlinable
    @_disfavoredOverload
    public func encode<T: Encodable>(_ value: T) throws -> SWONData {
        let encoder = SWONEncoding(codingKey: nil)
        try value.encode(to: encoder)
        return encoder.storage
    }

    @inlinable
    public func encode<T: Encodable>(_ value: T) throws -> Data {
        let output: String = try encode(value)
        return Data(output.utf8)
    }

    @inlinable
    @_disfavoredOverload
    public func encode<T: Encodable>(_ value: T) throws -> String {
        let swonData: SWONData = try encode(value)
        let options = SWONWriter.Options(
            indentation: indentation,
            prettyPrint: prettyPrint,
            sortKeys: sortKeys
        )
        return SWONWriter.dump(swonData, options: options)
    }
}

@usableFromInline
class SWONEncoding: Encoder {
    @usableFromInline
    enum Key: CodingKey {
        @inlinable
        var stringValue: String {
            switch self {
            case .index(let value), .integer(let value):
                String(value)
            case .string(let value):
                value
            }
        }

        @inlinable
        init?(stringValue: String) {
            self = .string(stringValue)
        }

        @inlinable
        var intValue: Int? {
            switch self {
            case .index(let value), .integer(let value):
                value
            case .string(let value):
                Int(value)
            }
        }

        @inlinable
        init?(intValue: Int) {
            self = .integer(intValue)
        }
        
        case index(Int)
        case string(String)
        case integer(Int)
    }
    @usableFromInline
    unowned(unsafe) let parent: SWONEncoding?

    @usableFromInline
    var codingKey: Key?

    @usableFromInline
    var codingPath: [CodingKey] {
        var path = [CodingKey]()
        var encoding = self
        while let parent = encoding.parent {
            if let codingKey {
                path.append(codingKey)
            }
            encoding = parent
        }
        return path.reversed()
    }

    @usableFromInline
    var userInfo: [CodingUserInfoKey: Any] {
        [:]
    }

    @usableFromInline
    var storage: SWONData = .nil

    @inlinable
    init(codingKey: Key?, parent: SWONEncoding? = nil) {
        self.codingKey = codingKey
        self.parent = parent
    }

    func withStorageAssumingDictionary<T, E: Error>(
        _ handler: (inout [String: SWONData]) throws(E) -> T
    ) throws(E) -> T {
        guard case .dictionary(var dict) = storage else {
            fatalError("assumed currently encoding dictionary, but found \(storage)")
        }
        storage = .nil
        let result = try handler(&dict)
        storage = .dictionary(dict)
        return result
    }

    func withStorageAssumingArray<T, E: Error>(
        _ handler: (inout [SWONData]) throws(E) -> T
    ) throws(E) -> T {
        guard case .array(var array) = storage else {
            fatalError("assumed currently encoding array, but found \(storage)")
        }
        storage = .nil
        let result = try handler(&array)
        storage = .array(array)
        return result
    }

    @usableFromInline
    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        storage = .dictionary([:])
        let container = SWONKeyedEncodingContainer<Key>(encoder: self)
        return KeyedEncodingContainer(container)
    }

    @usableFromInline
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        storage = .array([])
        return SWONUnkeyedEncodingContainer(encoder: self)
    }

    @usableFromInline
    func singleValueContainer() -> SingleValueEncodingContainer {
        return SWONSingleValueEncodingContainer(encoder: self)
    }
}
