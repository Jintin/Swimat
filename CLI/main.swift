import CoreServices
import Foundation

enum FileType {
    case nonexistent
    case file
    case directory
}

extension URL {
    var children: [URL] {
        return (try? FileManager.default
                .contentsOfDirectory(atPath: self.path).map {
                    URL(fileURLWithPath: $0, relativeTo: self)
            }) ?? []
    }

    var fileType: FileType {
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory) {
            if isDirectory.boolValue {
                return .directory
            } else {
                return .file
            }
        } else {
            return .nonexistent
        }
    }
}

func expandDirectory(at path: String, recursively: Bool) -> [URL] {
    let parent = URL(fileURLWithPath: path)
    switch parent.fileType {
    case .directory:
        var files = [URL]()
        for child in parent.children {
            if recursively && child.fileType == .directory {
                files.append(contentsOf: expandDirectory(at: child.path, recursively: recursively))
            } else {
                files.append(child)
            }
        }
        return files
    case .file:
        return [parent]
    case .nonexistent:
        return []
    }
}

let options = Options.shared
let paths = options.parseArguments(Array(CommandLine.arguments.dropFirst()))
var files = 0
for path in paths {
    for file in expandDirectory(at: path, recursively: options.recursive) {
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
            (file.pathExtension) as CFString,
            nil)?.takeRetainedValue(),
            uti == "public.swift-source" as CFString {
            let parser = SwiftParser(string: try String(contentsOf: file), preferences: options.preference)
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
