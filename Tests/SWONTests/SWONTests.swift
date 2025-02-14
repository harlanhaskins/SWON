import Testing
import Foundation
@testable import SWON
import SwiftParser
import SwiftSyntax

@Test func decoder() throws {
    struct CodableStruct: Codable, Equatable {
        var woo: Int
        var test: [Int]
        var uhHuh: Bool
        var you: Nested
        var what: String?
    }

    struct Nested: Codable, Equatable {
        var yeah: String
    }

    let swon = """
    [
        "test": [1, 2, 3],
        "uhHuh": false,
        "what": nil,
        "woo": 123,
        "you": [
            "yeah": "you"
        ]
    ]
    """
    let expected = CodableStruct(
        woo: 123,
        test: [1, 2, 3],
        uhHuh: false,
        you: Nested(yeah: "you")
    )
    let decoder = SWONDecoder()
    let actual = try decoder.decode(CodableStruct.self, from: Data(swon.utf8))
    #expect(actual == expected)

    let encoder = SWONEncoder()
    let reEncoded: String = try encoder.encode(actual)
    let reDecoded = try decoder.decode(CodableStruct.self, from: Data(reEncoded.utf8))
    #expect(actual == reDecoded)
}

@Test func parseSampleFile() throws {
    struct SampleFile: Codable {
        var hello: String
        var this: [String]
        var its: [String: [String]]
        var productionReady: Bool
        var support: String?
        var bugs: Int64
    }
    let file = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "Resources/SampleFile.swon")
    let contents = try String(contentsOf: file)
    let decoded = try SWONDecoder().decode(SampleFile.self, from: Data(contents.utf8))
    #expect(decoded != nil)
}

@Test func example() throws {
    let swon = SWONParser.parse("""
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
    #expect(swon == [
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

@Test func encoderPrettyPrinting() throws {
    struct Content: Codable, Equatable {
        var def: String
        var abc: String
        var children: [Int]
        var dicts: [[String: Int]]
    }

    let content = Content(def: "abc", abc: "def", children: [1, 2, 3], dicts: [
        ["Hello": 1],
        ["World": 9900]
    ])
    var encoder = SWONEncoder()
    encoder.sortKeys = true

    let prettyOutput: String = try encoder.encode(content)
    #expect(prettyOutput == #"""
        [
            "abc": "def",
            "children": [1, 2, 3],
            "def": "abc",
            "dicts": [
                ["Hello": 1],
                ["World": 9900]
            ]
        ]
        """#)

    encoder.prettyPrint = false
    let terseOutput: String = try encoder.encode(content)
    #expect(terseOutput == #"["abc":"def","children":[1,2,3],"def":"abc","dicts":[["Hello":1],["World":9900]]]"#)
}

@Test func foundationDataTypes() throws {
    struct FoundationDataTypes: Codable, Equatable {
        var date = Date(timeIntervalSince1970: 1712937928)
        var url = URL(string: "https://harlanhaskins.com")
        var data: Data = Data([0x01, 0x02, 0x03])
        var simd: SIMD4<Float> = [1, 2, 3, 4]
    }

    let data = FoundationDataTypes()
    let output: String = try SWONEncoder().encode(data)
    let roundTrip = try SWONDecoder().decode(FoundationDataTypes.self, from: Data(output.utf8))
    #expect(roundTrip == data)
}
