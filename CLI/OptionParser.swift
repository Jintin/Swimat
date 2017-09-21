import Foundation

struct Option {
    let options: [String]
    let helpArguments: String
    let helpText: String
    let number: Int
    let setter: ([String]) -> Void
}

class Options {
    static var shared = Options()

    var recursive = false
    var verbose = false

    init() {
        Indent.char = "\t"
    }

    static let options: [Option] = [
        Option(options: ["-h", "--help"],
            helpArguments: "",
            helpText: "Display this help message.",
            number: 0,
            setter: { _ in
                printHeader()
                printOptions()
                exit(.success)
            }),
        Option(options: ["-i", "--indent"],
            helpArguments: "<value>=-1",
            helpText: "Set the number of spaces to indent; use -1 for tabs.",
            number: 1,
            setter: { indentSize in
                guard indentSize.count == 1, let indentSize = Int(indentSize[0]) else {
                    printToError("Invalid indent size")
                    exit(.invalidIndent)
                }
                if indentSize < 0 {
                    Indent.char = "\t"
                } else {
                    Indent.char = String(repeating: " ", count: indentSize)
                }
            }),
        Option(options: ["-r", "--recursive"],
            helpArguments: "",
            helpText: "Search and format directories recursively.",
            number: 0,
            setter: { _ in
                shared.recursive = true
            }),
        Option(options: ["-v", "--verbose"],
            helpArguments: "",
            helpText: "Enable verbose output.",
            number: 0,
            setter: { _ in
                shared.verbose = true
            })
    ]

    static func printHeader() {
        printToError("The Swimat Swift formatter")
        printToError()
        printToError("USAGE: swimat [options] <inputs...>")
        printToError()
        printToError("OPTIONS:")
    }

    static func printOptions() {
        for option in options {
            let optionsString = " \(option.options.joined(separator: ", ")) \(option.helpArguments)"
                .padding(toLength: 25, withPad: " ", startingAt: 0)
            printToError("\(optionsString)\(option.helpText)")
        }
    }

    func parseArguments(_ arguments: [String]) -> [String] {
        if arguments.isEmpty {
            Options.printHeader()
            Options.printOptions()
            exit(.noArguments)
        }

        var files = [String]()

        var i = 0
        while i < arguments.count {
            let argument = arguments[i]
            i += 1
            if argument.hasPrefix("-") {
                var validOption = false
                for option in Options.options {
                    if option.options.contains(argument) {
                        let startIndex = min(i, arguments.count)
                        let endIndex = min(i + option.number, arguments.count)
                        option.setter(Array(arguments[startIndex..<endIndex]))
                        i = endIndex
                        validOption = true
                    }
                }
                if !validOption {
                    printToError("Invalid option \(argument). Valid options are:")
                    Options.printOptions()
                    exit(.invalidOption)
                }
            } else {
                files.append(argument)
            }
        }

        return files
    }

}
