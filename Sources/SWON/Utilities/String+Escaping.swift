//
//  String+Escaping.swift
//  SWON
//
//  Created by Harlan Haskins on 2/15/25.
//

extension String {
    var swonEscaped: String {
        var s = ""
        for c in self {
            switch c {
            case "\"":
                s.append("\\")
                s.append("\"")
            case "\n":
                s.append("\\")
                s.append("n")
            case "\t":
                s.append("\\")
                s.append("t")
            default:
                s.append(c)
            }
        }
        return s
    }
}
