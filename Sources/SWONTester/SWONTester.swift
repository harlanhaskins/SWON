//
//  SWONTester.swift
//  SWON
//
//  Created by Harlan Haskins on 2/14/25.
//

import Darwin
import SWON
import Foundation

@_optimize(none)
func blackHole<T>(_ value: T) {}

@main
struct SWONTester {
    static func main() throws {
        let value = A()
        var encoder = SWONEncoder()
        for _ in 0..<1000 {
            blackHole(try encoder.encode(value))
        }
        sleep(1)
        let jsonEncoder = JSONEncoder()
        for _ in 0..<1000 {
            blackHole(try jsonEncoder.encode(value))
        }
    }
}

struct A: Codable, Equatable {
    var x0: [String]
    var x1: [String]
    var x2: [String]
    var x3: [String]
    var x4: [String]
    var x5: [String]
    var x6: [String]
    var x7: [String]
    var x8: [String]
    var x9: [String]
    var x10: [String]
    var x11: [String]
    var x12: [String]
    var x13: [String]
    var x14: [String]
    var x15: [String]
    var x16: [String]
    var x17: [String]
    var x18: [String]
    var x19: [String]

    init() {
        x0 = [String](repeating: "Hello, world", count: 100)
        x1 = x0
        x2 = x0
        x3 = x0
        x4 = x0
        x5 = x0
        x6 = x0
        x7 = x0
        x8 = x0
        x9 = x0
        x10 = x0
        x11 = x0
        x12 = x0
        x13 = x0
        x14 = x0
        x15 = x0
        x16 = x0
        x17 = x0
        x18 = x0
        x19 = x0
    }
}
