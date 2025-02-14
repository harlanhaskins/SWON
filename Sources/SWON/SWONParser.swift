//
//  SWONParser.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

import SwiftSyntax
import SwiftParser

public enum SWONParser {
    static func parse(_ node: ExprSyntax) -> SWONData? {
        switch node.kind {
        case .arrayExpr:
            // parse children
            var items = [SWONData]()
            let array = node.as(ArrayExprSyntax.self)!
            for child in array.elements {
                let elt = child.expression
                if let data = parse(elt) {
                    items.append(data)
                }
            }
            return .array(items)
        case .dictionaryExpr:
            let dict = node.as(DictionaryExprSyntax.self)!
            switch dict.content {
            case .colon:
                return .dictionary([:])
            case .elements(let elements):
                var dict = [String: SWONData]()
                for element in elements {
                    let key = element.key
                    guard let string = key.as(StringLiteralExprSyntax.self), let literalValue = string.stringLiteralValue else {
                        print("dictionary keys must be strings without interpolation")
                        continue
                    }
                    let value = element.value
                    if let data = parse(value) {
                        dict[literalValue] = data
                    }
                }
                return .dictionary(dict)
            }
        case .stringLiteralExpr:
            let literalExpr = node.as(StringLiteralExprSyntax.self)!
            guard let stringLiteralValue = literalExpr.stringLiteralValue else {
                print("interpolation is not supported")
                return nil
            }
            return .string(stringLiteralValue)
        case .integerLiteralExpr:
            let literalExpr = node.as(IntegerLiteralExprSyntax.self)!
            guard let literalValue = Int64(literalExpr.literal.text.replacing("_", with: "")) else {
                print("invalid integer literal: \(literalExpr.literal.text)")
                return nil
            }
            return .integer(literalValue)
        case .booleanLiteralExpr:
            let value = node.as(BooleanLiteralExprSyntax.self)!
            return .bool(value.literal.tokenKind == .keyword(.true))
        case .floatLiteralExpr:
            let value = node.as(FloatLiteralExprSyntax.self)!
            guard let double = Double(value.literal.text) else {
                print("invalid floating point literal: \(value.literal.text)")
                return nil
            }
            return .float(double)
        case .nilLiteralExpr:
            return .nil
        default:
            return nil
        }
    }

    public static func parse(_ string: String) -> SWONData? {
        let sourceFile = Parser.parse(source: string)
        guard let expr = sourceFile.statements.first?.item.as(ExprSyntax.self) else {
            return nil
        }
        return parse(expr)
    }
}

extension StringLiteralExprSyntax {
    var stringLiteralValue: String? {
        guard
            segments.count == 1,
            let stringSegment = segments.first?.as(StringSegmentSyntax.self)
        else {
            return nil
        }
        return stringSegment.content.text
    }
}
