import Foundation

func printToError(_ string: String = "") {
    guard let data = "\(string)\n".data(using: .utf8) else {
        return
    }
    FileHandle.standardError.write(data)
}

enum SwimatError: Int32 {
    case success = 0
    case noArguments
    case invalidOption
    case invalidIndent
}

func exit(_ error: SwimatError) -> Never {
    exit(error.rawValue)
}
