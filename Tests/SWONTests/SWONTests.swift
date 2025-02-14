import Testing
@testable import SWON
import SwiftParser
import SwiftSyntax

@Test func example() async throws {
    let SWON = SWONParser.parse("""
        [
            "hello": 123,
            "goodbye": 495.0,
            "children": [
                "test",
                3,
                4.3,
                ["abc": 10e3],
                100_000
            ]
        ]
        """)
    #expect(SWON == [
        "hello": 123,
        "goodbye": 495.0,
        "children": [
            "test",
            3,
            4.3,
            ["abc": 10e3],
            100_000
        ]
    ])
}
