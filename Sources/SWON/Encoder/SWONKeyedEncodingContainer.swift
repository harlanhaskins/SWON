//
//  SWONKeyedEncodingContainer.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

struct SWONKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    let codingPath: [CodingKey]
    let encoder: SWONEncoding

    init(encoder: SWONEncoding) {
        self.encoder = encoder
        self.codingPath = encoder.codingPath
    }

    private mutating func encodeInteger<T: BinaryInteger>(_ value: T, forKey key: K) throws {
        encoder.withStorageAssumingDictionary { dict in
            dict[key.stringValue] = .integer(Int64(value))
        }
    }

    mutating func encode(_ value: String, forKey key: K) throws {
        encoder.withStorageAssumingDictionary { dict in
            dict[key.stringValue] = .string(value)
        }
    }

    mutating func encode(_ value: Double, forKey key: K) throws {
        encoder.withStorageAssumingDictionary { dict in
            dict[key.stringValue] = .float(value)
        }
    }

    mutating func encode(_ value: Float, forKey key: K) throws {
        encoder.withStorageAssumingDictionary { dict in
            dict[key.stringValue] = .float(Double(value))
        }
    }

    mutating func encode(_ value: Bool, forKey key: K) throws {
        encoder.withStorageAssumingDictionary { dict in
            dict[key.stringValue] = .bool(value)
        }
    }

    mutating func encodeNil(forKey key: K) throws {
        encoder.withStorageAssumingDictionary { dict in
            dict[key.stringValue] = .nil
        }
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: K) throws {
        try encoder.withStorageAssumingDictionary { dict in
            let nestedEncoder = SWONEncoding(
                codingKey: .string(key.stringValue),
                parent: encoder
            )
            try value.encode(to: nestedEncoder)
            dict[key.stringValue] = nestedEncoder.storage
        }
    }

    mutating func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> {
        encoder.withStorageAssumingDictionary { dict in
            let nestedEncoder = SWONEncoding(
                codingKey: .string(key.stringValue),
                parent: encoder
            )
            nestedEncoder.storage = .dictionary([:])
            return KeyedEncodingContainer(SWONKeyedEncodingContainer<NestedKey>(encoder: nestedEncoder))
        }
    }

    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        encoder.withStorageAssumingDictionary { dict in
            let nestedEncoder = SWONEncoding(
                codingKey: .string(key.stringValue),
                parent: encoder
            )
            nestedEncoder.storage = .array([])
            return SWONUnkeyedEncodingContainer(encoder: nestedEncoder)
        }
    }

    mutating func superEncoder() -> Encoder {
        return encoder
    }

    mutating func superEncoder(forKey key: K) -> Encoder {
        return encoder
    }
}
