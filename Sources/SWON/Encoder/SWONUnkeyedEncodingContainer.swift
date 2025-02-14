//
//  SWONUnkeyedEncodingContainer.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

struct SWONUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    let codingPath: [CodingKey]
    let encoder: SWONEncoding
    private(set) var count: Int = 0

    init(encoder: SWONEncoding) {
        self.encoder = encoder
        self.codingPath = encoder.codingPath
    }

    private mutating func encodeInteger<T: BinaryInteger>(_ value: T) throws {
        encoder.withStorageAssumingArray { array in
            array.append(.integer(Int64(value)))
            count += 1
        }
    }

    mutating func encode(_ value: String) throws {
        encoder.withStorageAssumingArray { array in
            array.append(.string(value))
            count += 1
        }
    }

    mutating func encode(_ value: Double) throws {
        encoder.withStorageAssumingArray { array in
            array.append(.float(value))
            count += 1
        }
    }

    mutating func encode(_ value: Float) throws {
        encoder.withStorageAssumingArray { array in
            array.append(.float(Double(value)))
            count += 1
        }
    }

    mutating func encode(_ value: Bool) throws {
        encoder.withStorageAssumingArray { array in
            array.append(.bool(value))
            count += 1
        }
    }

    mutating func encodeNil() throws {
        encoder.withStorageAssumingArray { array in
            array.append(.nil)
            count += 1
        }
    }

    mutating func encode<T: Encodable>(_ value: T) throws {
        try encoder.withStorageAssumingArray { array in
            let nestedEncoder = SWONEncoding()
            nestedEncoder.codingPath = self.codingPath + [IndexKey(intValue: count)!]
            try value.encode(to: nestedEncoder)
            array.append(nestedEncoder.storage)
            count += 1
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        encoder.withStorageAssumingArray { array in
            let nestedEncoder = SWONEncoding()
            nestedEncoder.codingPath = self.codingPath + [IndexKey(intValue: count)!]
            nestedEncoder.storage = .dictionary([:])
            array.append(nestedEncoder.storage)
            count += 1
            return KeyedEncodingContainer(SWONKeyedEncodingContainer<NestedKey>(encoder: nestedEncoder))
        }
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        encoder.withStorageAssumingArray { array in
            let nestedEncoder = SWONEncoding()
            nestedEncoder.codingPath = self.codingPath + [IndexKey(intValue: count)!]
            nestedEncoder.storage = .array([])
            array.append(nestedEncoder.storage)
            count += 1
            return SWONUnkeyedEncodingContainer(encoder: nestedEncoder)
        }
    }

    mutating func superEncoder() -> Encoder {
        return encoder
    }
}

private struct IndexKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = Int(stringValue)
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}
