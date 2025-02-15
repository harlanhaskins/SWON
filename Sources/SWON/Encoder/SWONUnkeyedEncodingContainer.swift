//
//  SWONUnkeyedEncodingContainer.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

struct SWONUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    let codingPath: [CodingKey]
    let encoder: SWONEncoding

    var count: Int {
        encoder.withStorageAssumingArray { $0.count }
    }

    init(encoder: SWONEncoding) {
        self.encoder = encoder
        self.codingPath = encoder.codingPath
    }

    private mutating func encodeInteger<T: BinaryInteger>(_ value: T) throws {
        encoder.withStorageAssumingArray { array in
            array.append(.integer(Int64(value)))
        }
    }

    mutating func encode(_ value: String) throws {
        encoder.withStorageAssumingArray { array in
            array.append(.string(value))
        }
    }

    mutating func encode(_ value: Double) throws {
        encoder.withStorageAssumingArray { array in
            array.append(.float(value))
        }
    }

    mutating func encode(_ value: Float) throws {
        encoder.withStorageAssumingArray { array in
            array.append(.float(Double(value)))
        }
    }

    mutating func encode(_ value: Bool) throws {
        encoder.withStorageAssumingArray { array in
            array.append(.bool(value))
        }
    }

    mutating func encodeNil() throws {
        encoder.withStorageAssumingArray { array in
            array.append(.nil)
        }
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
        try encoder.withStorageAssumingArray { array in
            let nestedEncoder = SWONEncoding(
                codingKey: .index(array.count),
                parent: encoder)
            try value.encode(to: nestedEncoder)
            array.append(nestedEncoder.storage)
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        encoder.withStorageAssumingArray { array in
            let nestedEncoder = SWONEncoding(
                codingKey: .index(array.count),
                parent: encoder)
            nestedEncoder.storage = .dictionary([:])
            return KeyedEncodingContainer(SWONKeyedEncodingContainer<NestedKey>(encoder: nestedEncoder))
        }
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        encoder.withStorageAssumingArray { array in
            let nestedEncoder = SWONEncoding(
                codingKey: .index(array.count),
                parent: encoder)
            nestedEncoder.storage = .array([])
            return SWONUnkeyedEncodingContainer(encoder: nestedEncoder)
        }
    }

    mutating func superEncoder() -> Encoder {
        return encoder
    }
}
