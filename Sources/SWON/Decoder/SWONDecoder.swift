import Foundation

final class SWONDecoding: Decoder {
    var data: SWONData
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]

    init(data: SWONData) {
        self.data = data
    }

    func withCurrentKey<T, E: Error>(
        _ key: some CodingKey,
        perform action: () throws(E) -> T
    ) throws(E) -> T {
        codingPath.append(key)
        defer {
            codingPath.removeLast()
        }
        return try action()
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        let container = SWONKeyedDecodingContainer<Key>(decoder: self, data: data)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard case .array(let array) = data else {
            throw DecodingError.typeMismatch(
                [Any].self,
                .init(
                    codingPath: codingPath,
                    debugDescription: "Expected to decode array but found \(data)"
                )
            )
        }
        return SWONUnkeyedDecodingContainer(decoder: self, array: array)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SWONSingleValueDecodingContainer(decoder: self, data: data)
    }
}

public struct SWONDecoder {
    public init() {}

    public func decode<T: Decodable>(_ type: T.Type, from swon: String) throws -> T {
        guard let swonData = SWONParser.parse(swon) else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: [], debugDescription: "Unable to parse SWON")
            )
        }
        let decoder = SWONDecoding(data: swonData)
        return try T.init(from: decoder)
    }

    public func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        try decode(type, from: String(decoding: data, as: UTF8.self))
    }
}
