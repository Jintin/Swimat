import CoreServices
import Foundation

let options = Options.shared
let paths = options.parseArguments(Array(CommandLine.arguments.dropFirst()))
for path in paths {
    let file = URL(fileURLWithPath: path)
    if FileManager.default.fileExists(atPath: file.path),
		let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                       (file.pathExtension) as CFString,
                                                       nil)?.takeRetainedValue(),
        uti == "public.swift-source" as CFString {
            let parser = SwiftParser(string: try String(contentsOf: file))
            let formattedText = try parser.format()
            try formattedText.write(to: file, atomically: true, encoding: .utf8)
            print("\(path) was formatted successfully.")
    } else {
            print("\(path) doesn't appear to be a Swift file. Skipping.")
    }
}
