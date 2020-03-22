#!/usr/bin/env xcrun --sdk macosx swift

// Douglas Hill, February 2018

import Foundation

extension URL {
    public func appendingPathComponents(_ pathComponents: [String]) -> URL {
        return pathComponents.enumerated().reduce(self) { url, pair in
            return url.appendingPathComponent(pair.element, isDirectory: pair.offset + 1 < pathComponents.count)
        }
    }
}

let projectDirectory = URL(fileURLWithPath: ProcessInfo.processInfo.environment["PROJECT_DIR"]!)
let inputStringsFile = projectDirectory.appendingPathComponents(["KeyboardKit", "Localised", "en.lproj", "Localizable.strings"])
let outputSwiftFile = projectDirectory.appendingPathComponents(["KeyboardKit", "LocalisedStringKeys.swift"])

let stringsDictionary = NSDictionary(contentsOf: inputStringsFile)!
let keys = stringsDictionary.allKeys as! [String]
let enumCases = keys.sorted().map { "    case \($0)" }.joined(separator: "\n")

let contents = """
// This file was automatically generated from \((#file as NSString).lastPathComponent).

enum LocalisedStringKey: String {
\(enumCases)
}

"""

let oldContents = try? String(contentsOf: outputSwiftFile)
if contents != oldContents {
    try! contents.write(to: outputSwiftFile, atomically: false, encoding: .utf8)
}
