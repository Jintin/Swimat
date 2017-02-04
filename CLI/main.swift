import CoreServices
import Foundation

enum FileType {
    case nonexistant
    case file
    case directory
}

func getFileType(for file: URL) -> FileType {
    var isDirectory: ObjCBool = false
    if FileManager.default.fileExists(atPath: file.path, isDirectory: &isDirectory) {
        if isDirectory.boolValue {
            return .directory
        } else {
            return .file
        }
    } else {
        return .nonexistant
    }
}

func expandDirectory(at path: String, recursively: Bool) -> [URL] {
    let parent = URL(fileURLWithPath: path)
    switch getFileType(for: parent) {
    case .directory:
        var files = [URL]()
        for child in (try? FileManager.default.contentsOfDirectory(atPath: parent.path).map({ URL(fileURLWithPath: $0, relativeTo: parent) })) ?? [] {
            if recursively && getFileType(for: child) == .directory {
                files.append(contentsOf: expandDirectory(at: child.path, recursively: recursively))
            } else {
                files.append(child)
            }
        }
        return files
    case .file:
        return [parent]
    case .nonexistant:
        return []
    }
}

let options = Options.shared
let paths = options.parseArguments(Array(CommandLine.arguments.dropFirst()))
var files = 0
for path in paths {
    let file = URL(fileURLWithPath: path)
    for file in expandDirectory(at: path, recursively: options.recursive) {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                           (file.pathExtension) as CFString,
                                                           nil)?.takeRetainedValue(),
            uti == "public.swift-source" as CFString {
                let parser = SwiftParser(string: try String(contentsOf: file))
                let formattedText = try parser.format()
                try formattedText.write(to: file, atomically: true, encoding: .utf8)
                files += 1
                if options.verbose {
                    print("\(file.path) was formatted successfully.")
                }
            }
    }
}
print("Finished formatting \(files) files.")
