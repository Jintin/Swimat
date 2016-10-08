import CoreServices
import Foundation

enum SwimatError: Int32 {
    case noArguments = 1
    case invalidOption
    case invalidIndent
}

var indentSize = 0
var indent: String {
    if indentSize <= 0 {
        return "\t"
    } else {
        return String(repeating: " ", count: indentSize)
    }
}
var force = false

var lookingForIndent = false

func printToError(_ string: String = "") {
    guard let data = "\(string)\n".data(using: .utf8) else {
        return
    }
    FileHandle.standardError.write(data)
}


if CommandLine.arguments.count < 2 {
    printToError("The Swimat Swift formatter")
    printToError()
    printToError("USAGE: swimat <options/inputs...>")
    printToError()
    printToError("OPTIONS:")
    printToError("-i <value>=0 Set number of spaces to indent for subsequent files, 0 for tabs.")
    printToError("-f           Toggle force-formatting for all subsequent files.")
    exit(SwimatError.noArguments.rawValue)
}
for var argument in CommandLine.arguments.dropFirst() {
    if argument.hasPrefix("-") {
        argument.remove(at: argument.startIndex)
        switch argument {
        case "f":
            force = !force
        case "i":
            lookingForIndent = true
        default:
            printToError("-\(argument) is not a valid option.\nValid options are -i and -f.")
            exit(SwimatError.invalidOption.rawValue)
        }
    } else {
        if (lookingForIndent) {
            guard let size = Int(argument) else {
                printToError("\(argument) is not a valid indent size. Exiting.")
                exit(SwimatError.invalidIndent.rawValue)
            }
            indentSize = size
            lookingForIndent = false
        } else {
            let file = URL(fileURLWithPath: argument)
            if force || UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (file.pathExtension) as CFString, nil)?.takeRetainedValue() as? String ?? "" == "public.swift-source" {
                SwiftParser.indentChar = indent
                let parser = SwiftParser(string: try String(contentsOf: file))
                let formattedText = try parser.format()
                try formattedText.write(to: file, atomically: true, encoding: .utf8)
                print("\(argument) was formatted successfully.")
            } else {
                print("\(argument) doesn't appear to be a Swift file. Skipping.")
            }
        }
    }
}
