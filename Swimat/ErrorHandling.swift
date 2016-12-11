import Foundation

func printToError(_ string: String = "") {
    guard let data = "\(string)\n".data(using: .utf8) else {
        return
    }
    FileHandle.standardError.write(data)
}

enum SwimatError: Int32 {
    case noArguments = 1
    case invalidOption
    case invalidIndent
}
