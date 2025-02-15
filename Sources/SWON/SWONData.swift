import Foundation
import SwiftParser
import SwiftSyntax

public enum SWONData: Equatable {
    case integer(Int64)
    case float(Double)
    case string(String)
    case bool(Bool)
    case array([SWONData])
    case dictionary([String: SWONData])
    case `nil`
}

private func a(_ c: Character) -> UInt8 {
    c.asciiValue!
}

public func jsonToSWON(_ data: Data) -> Data {
    var data = data
    struct Bracket {
        var index: Int
        var isDictionary: Bool = false
    }
    var isInString = false
    for i in 0..<data.count {
        if data[i] == a("\"") && i > 0 && data[i - 1] != a("\\") {
            isInString.toggle()
            continue
        }

        if isInString { continue }
        if data[i] == a("{") {
            data[i] = a("[")
        } else if data[i] == a("}") {
            data[i] = a("]")
        }
    }
    return data
}

extension SWONData: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .nil
    }
}

extension SWONData: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .integer(Int64(value))
    }
}

extension SWONData: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .float(Double(value))
    }
}

extension SWONData: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension SWONData: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension SWONData: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, SWONData)...) {
        var values = [String: SWONData]()
        for (key, value) in elements {
            values[key] = value
        }
        self = .dictionary(values)
    }
}

extension SWONData: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: SWONData...) {
        self = .array(elements)
    }
}
