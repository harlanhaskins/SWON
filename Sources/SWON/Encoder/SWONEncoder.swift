//
//  SWONEncoder.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

import Foundation

public struct SWONEncoder {
    public var indentation: Int = 4
    public var prettyPrint: Bool = true
    public var sortKeys: Bool = false

    public init() {}

    @_disfavoredOverload
    public func encode<T: Encodable>(_ value: T) throws -> SWONData {
        let encoder = SWONEncoding()
        try value.encode(to: encoder)
        return encoder.storage
    }

    public func encode<T: Encodable>(_ value: T) throws -> Data {
        let output: String = try encode(value)
        return Data(output.utf8)
    }

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

class SWONEncoding: Encoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    var storage: SWONData = .nil

    func withStorageAssumingDictionary<T, E: Error>(
        _ handler: (inout [String: SWONData]) throws(E) -> T
    ) throws(E) -> T {
        guard case .dictionary(var dict) = storage else {
            fatalError()
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
            fatalError()
        }
        storage = .nil
        let result = try handler(&array)
        storage = .array(array)
        return result
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        storage = .dictionary([:])
        let container = SWONKeyedEncodingContainer<Key>(encoder: self)
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        storage = .array([])
        return SWONUnkeyedEncodingContainer(encoder: self)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        return SWONSingleValueEncodingContainer(encoder: self)
    }
}
