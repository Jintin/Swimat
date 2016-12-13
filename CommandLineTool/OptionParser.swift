import Foundation

struct Option {
    var shortOption: String
    var helpText: String
    var number: Int
    var setter: ([String]) -> Void
}

struct Options {
    static var shared = Options()

    init() {
        Indent.char = "\t"
        Indent.size = 1
    }

    static let options: [Option] = [
        Option(shortOption: "i",
               helpText: "-i <value>=0 Set the number of spaces to indent; use 0 for tabs.",
               number: 1,
               setter: { indentSize in
            guard indentSize.count == 1, let indentSize = Int(indentSize[0]) else {
                printToError("Invalid indent size")
                exit(SwimatError.invalidIndent.rawValue)
            }
            if indentSize <= 0 {
                Indent.char = "\t"
                Indent.size = 1
            } else {
                Indent.char = String(repeating: " ", count: indentSize)
                Indent.size = indentSize
            }
        })]

    static func printOptions() {
        for option in options.sorted(by: { $0.shortOption < $1.shortOption }) {
            printToError(option.helpText)
        }
    }

    func parseArguments(_ arguments: [String]) -> [String] {
        if arguments.isEmpty {
            printToError("The Swimat Swift formatter")
            printToError()
            printToError("USAGE: swimat [options] <inputs...>")
            printToError()
            printToError("OPTIONS:")
            Options.printOptions()
            exit(SwimatError.noArguments.rawValue)
        }

        var files = [String]()

        var i = 0
        while i < arguments.count {
            var argument = arguments[i]
            i += 1
            if argument.hasPrefix("-") {
                argument.remove(at: argument.startIndex)
                var validOption = false
                for option in Options.options {
                    if option.shortOption == argument {
                        let startIndex = min(i, arguments.count)
                        let endIndex = min(i + option.number, arguments.count)
                        option.setter(Array(arguments[startIndex..<endIndex]))
                        i = endIndex
                        validOption = true
                    }
                }
                if !validOption {
                    printToError("Invalid option -\(argument). Valid options are:")
                    Options.printOptions()
                    exit(SwimatError.invalidOption.rawValue)
                }
            } else {
                files.append(argument)
            }
        }

        return files
    }
}
