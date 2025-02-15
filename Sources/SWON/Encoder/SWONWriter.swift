//
//  SWONWriter.swift
//  SWON
//
//  Created by Harlan Haskins on 2/13/25.
//

extension SWONData {
    var isSimple: Bool {
        if case .dictionary = self { return false }
        if case .array = self { return false }
        return true
    }
}

@usableFromInline
struct SWONWriter {
    @usableFromInline
    struct Options {
        @usableFromInline
        var indentation: Int = 4

        @usableFromInline
        var prettyPrint: Bool = true

        @usableFromInline
        var sortKeys: Bool = false

        @inlinable
        init(
            indentation: Int = 4,
            prettyPrint: Bool = true,
            sortKeys: Bool = false
        ) {
            self.indentation = indentation
            self.prettyPrint = prettyPrint
            self.sortKeys = sortKeys
        }
    }
    var indent: String
    var options: Options

    init(options: Options = .init()) {
        self.options = options
        self.indent = options.indentation == 0 ? "" : String(repeating: " ", count: options.indentation)
    }

    @usableFromInline
    static func dump(_ data: SWONData, options: Options = .init()) -> String {
        var s = ""
        let writer = SWONWriter(options: options)
        writer.write(data: data, to: &s)
        return s
    }

    func write(data: SWONData, to stream: inout (some TextOutputStream)) {
        writeImpl(data, level: 0, to: &stream)
    }

    func newline(_ stream: inout (some TextOutputStream)) {
        if options.prettyPrint {
            stream.write("\n")
        }
    }

    func space(_ stream: inout (some TextOutputStream)) {
        if options.prettyPrint {
            stream.write(" ")
        }
    }

    func indent(_ level: Int, to stream: inout (some TextOutputStream)) {
        if options.prettyPrint {
            for _ in 0..<level {
                stream.write(indent)
            }
        }
    }

    func writeCollection<Coll: Collection, Stream: TextOutputStream>(
        level: Int,
        collection: Coll,
        isAllSimple: Bool,
        to stream: inout Stream,
        writer: (Coll.Element, inout Stream) -> Void
    ) {
        stream.write("[")
        if !isAllSimple {
            newline(&stream)
        }
        for (index, element) in collection.enumerated() {
            if !isAllSimple {
                indent(level + 1, to: &stream)
            }
            writer(element, &stream)
            if index != collection.count - 1 {
                stream.write(",")
                if isAllSimple {
                    space(&stream)
                } else {
                    newline(&stream)
                }
            }
        }
        if !isAllSimple {
            newline(&stream)
            indent(level, to: &stream)
        }
        stream.write("]")
    }

    func writeArray(
        elements: [SWONData],
        level: Int,
        to stream: inout (some TextOutputStream)
    ) {
        let isAllSimple = elements.allSatisfy(\.isSimple)
        writeCollection(
            level: level,
            collection: elements,
            isAllSimple: isAllSimple,
            to: &stream
        ) { element, stream in
            writeImpl(element, level: level + 1, to: &stream)
        }
    }

    func writeDictionary(
        elements: [String: SWONData],
        level: Int,
        to stream: inout (some TextOutputStream)
    ) {
        let isAllSimple = elements.values.allSatisfy(\.isSimple)
        var keysAndValues = Array(elements)
        if options.sortKeys {
            keysAndValues.sort { $0.key < $1.key }
        }

        writeCollection(
            level: level,
            collection: keysAndValues,
            isAllSimple: isAllSimple,
            to: &stream
        ) { element, stream in
            writeImpl(.string(element.key), level: level + 1, to: &stream)
            stream.write(":")
            space(&stream)
            writeImpl(element.value, level: level + 1, to: &stream)
        }
    }

    func writeImpl(
        _ data: SWONData,
        level: Int,
        to stream: inout (some TextOutputStream)
    ) {
        switch data {
        case .array(let elements):
            writeArray(elements: elements, level: level, to: &stream)
        case .dictionary(let value):
            writeDictionary(elements: value, level: level, to: &stream)
        case .integer(let value):
            stream.write("\(value)")
        case .float(let value):
            stream.write("\(value)")
        case .string(let value):
            stream.write("\"\(value.swonEscaped)\"")
        case .bool(let value):
            stream.write("\(value)")
        case .nil:
            stream.write("nil")
        }
    }
}
