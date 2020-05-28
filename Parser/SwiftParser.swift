import Foundation

let operatorList: [Character: [String]] =
    [
        "+": ["+=<", "+=", "+++=", "+++", "+"],
        "-": ["->", "-=", "-<<"],
        "*": ["*=", "*"],
        "/": ["/=", "/"],
        "~": ["~=", "~~>", "~>"],
        "%": ["%=", "%"],
        "^": ["^="],
        "&": ["&&=", "&&&", "&&", "&=", "&+", "&-", "&*", "&/", "&%"],
        "<": ["<<<", "<<=", "<<", "<=", "<~~", "<~", "<--", "<-<", "<-", "<^>", "<|>", "<*>", "<||?", "<||", "<|?", "<|", "<"],
        ">": [">>>", ">>=", ">>-", ">>", ">=", ">->", ">"],
        "|": ["|||", "||=", "||", "|=", "|"],
        "!": ["!==", "!="],
        "=": ["===", "==", "="],
        ".": ["...", "..<", "."],
        "#": ["#>", "#"]
    ]

fileprivate let negativeCheckSigns: [Character] =
    ["+", "-", "*", "/", "&", "|", "^", "<", ">", ":", "(", "[", "{", "=", ",", ".", "?"]
fileprivate let negativeCheckKeys =
    ["case", "return", "if", "for", "while", "in"]
fileprivate let numbers: [Character] =
    ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

class SwiftParser {
    let string: String
    var retString = ""
    var strIndex: String.Index
    var indent = Indent()
    var indentStack = [Indent]()
    var newlineIndex: Int = 0
    var isNextSwitch: Bool = false
    var isNextEnum: Bool = false
    var autoRemoveChar: Bool = false

    init(string: String, preferences: Preferences? = nil) {
        self.string = string
        self.strIndex = string.startIndex

        if let preferences = preferences {
            // Use the preferences given (for example, when testing)
            Indent.paraAlign = preferences.areParametersAligned
            autoRemoveChar = preferences.areSemicolonsRemoved
        } else {
            // Fallback on user-defined preferences
            Indent.paraAlign = Preferences.areParametersAligned
            autoRemoveChar = Preferences.areSemicolonsRemoved
            return
        }
    }

    func format() throws -> String {
        while strIndex < string.endIndex {
            let char = string[strIndex]
            strIndex = try check(char: char)
        }
        removeUnnecessaryChar()
        return retString.trim()
    }

    func check(char: Character) throws -> String.Index {
        switch char {
        case "+", "*", "%", ">", "|", "=", "~", "^", "!", "&":
            if let index = space(with: operatorList[char]!) {
                return index
            }
            return add(char: char)
        case ".":
            if let index = add(with: operatorList[char]!) {
                return index
            }
            return add(char: char)
        case "-":
            return checkMinus(char: char)
        case "/":
            return checkSlash(char: char)
        case "<":
            return try checkLess(char: char)
        case "?":
            return try checkQuestion(char: char)
        case ":":
            return checkColon(char: char)
        case "#":
            return checkHash(char: char)
        case "\"":
            return try checkQuote(char: char)
        case "\n":
            return checkLineBreak(char: char)
        case " ", "\t":
            return checkSpace(char: char)
        case ",":
            return checkComma(char: char)
        case "{", "[", "(":
            return checkUpperBlock(char: char)
        case "}", "]", ")":
            return checkLowerBlock(char: char)
        default:
            return checkDefault(char: char)
        }
    }

    func checkMinus(char: Character) -> String.Index {
        if let index = space(with: operatorList[char]!) {
            return index
        } else {
            var noSpace = false
            if !retString.isEmpty {
                // check scientific notation
                if strIndex != string.endIndex {
                    if retString.last == "e" && numbers.contains(string[string.index(after: strIndex)]) {
                        noSpace = true
                    }
                }
                // check negative
                let last = retString.lastNonSpaceChar(retString.endIndex)
                if last.isAZ() {
                    if negativeCheckKeys.contains(retString.lastWord()) {
                        noSpace = true
                    }
                } else {
                    if negativeCheckSigns.contains(last) {
                        noSpace = true
                    }
                }
            }
            if noSpace {
                return add(char: char)
            }
            return space(with: "-")
        }
    }

    func checkSlash(char: Character) -> String.Index {
        if isNext(char: "/") {
            return addLine()
        } else if isNext(char: "*") {
            return addToNext(strIndex, stopWord: "*/")
        }
        return space(with: operatorList[char]!)!
    }

    func checkLess(char: Character) throws -> String.Index {
        if isNext(char: "#") {
            return add(string: "<#")
        }
        if let result = try string.findGeneric(from: strIndex), !isNext(char: " ") {
            retString += result.string
            return result.index
        }
        return space(with: operatorList[char]!)!
    }

    func checkQuestion(char: Character) throws -> String.Index {
        if isNext(char: "?") {
            // MARK: check double optional or nil check
            return add(string: "??")
        } else if let ternary = string.findTernary(from: strIndex) {
            retString.keepSpace()
            retString += ternary.string
            return ternary.index
        } else {
            return add(char: char)
        }
    }

    func checkColon(char: Character) -> String.Index {
        _ = checkInCase()
        trimWithIndent()
        retString += ": "
        return string.nextNonSpaceIndex(string.index(after: strIndex))
    }

    func checkHash(char: Character) -> String.Index {
        if isNext(string: "#if") {
            indent.count += 1
            return addLine() // MARK: bypass like '#if swift(>=3)'
        } else if isNext(string: "#else") {
            indent.count -= 1
            trimWithIndent()
            indent.count += 1
            return addLine() // bypass like '#if swift(>=3)'
        } else if isNext(string: "#endif") {
            indent.count -= 1
            trimWithIndent()
            return addLine() // bypass like '#if swift(>=3)'
        } else if isNext(char: "!") { // shebang
            return addLine()
        }
        if let index = checkHashQuote(index: strIndex, count: 0) {
            return index
        }
        if let index = add(with: operatorList[char]!) {
            return index
        }
        return add(char: char)
    }

    func checkHashQuote(index: String.Index, count: Int) -> String.Index? {
        switch string[index] {
        case "#":
            return checkHashQuote(index: string.index(after: index), count: count + 1)
        case "\"":
            return addToNext(strIndex, stopWord: "\"" + String(repeating: "#", count: count))
        default:
            return nil
        }
    }

    func checkQuote(char: Character) throws -> String.Index {
        if isNext(string: "\"\"\"") {
            strIndex = add(string: "\"\"\"")
            return addToNext(strIndex, stopWord: "\"\"\"")
        }
        let quote = try string.findQuote(from: strIndex)
        retString += quote.string
        return quote.index
    }

    func checkLineBreak(char: Character) -> String.Index {
        removeUnnecessaryChar()
        indent.line += 1
        return checkLine(char)
    }

    func checkSpace(char: Character) -> String.Index {
        if retString.lastWord() == "if" {
            let leading = retString.count - newlineIndex
            let newIndent = Indent(with: indent, offset: leading, type: IndentType(rawValue: "f"))
            indentStack.append(indent)
            indent = newIndent
        }
        retString.keepSpace()
        return string.index(after: strIndex)
    }

    func checkComma(char: Character) -> String.Index {
        trimWithIndent()
        retString += ", "
        return string.nextNonSpaceIndex(string.index(after: strIndex))
    }

    func checkUpperBlock(char: Character) -> String.Index {
        if char == "{" && indent.block == .ifelse {
            if let last = indentStack.popLast() {
                indent = last
                if indent.indentAdd {
                    indent.indentAdd = false
                }
            }
        }
        let offset = retString.count - newlineIndex
        let newIndent = Indent(with: indent, offset: offset, type: IndentType(rawValue: char))
        indentStack.append(indent)
        indent = newIndent
        if indent.block == .curly {
            if isNextSwitch {
                indent.inSwitch = true
                isNextSwitch = false
            }
            if isNextEnum {
                indent.inEnum = true
                isNextEnum = false
            }
            indent.count -= 1
            trimWithIndent()
            indent.count += 1
            if !retString.last.isUpperBlock() {
                retString.keepSpace()
            }

            retString += "{ "
            return string.nextNonSpaceIndex(string.index(after: strIndex))
        } else {
            if Indent.paraAlign && char == "(" && isNext(char: "\n") {
                indent.count += 1
            }
            retString.append(char)
            return string.nextNonSpaceIndex(string.index(after: strIndex))
        }
    }

    func checkLowerBlock(char: Character) -> String.Index {
        var addIndentBack = false
        if let last = indentStack.popLast() {
            indent = last
            if indent.indentAdd {
                indent.indentAdd = false
                addIndentBack = true
            }
        } else {
            indent = Indent()
        }

        if char == "}" {
            if isNext(char: ".", skipBlank: true) {
                trimWithIndent()
            } else {
                trimWithIndent(addExtra: false)
            }
            if addIndentBack {
                indent.count += 1
            }
            retString.keepSpace()
            let next = string.index(after: strIndex)
            if next < string.endIndex && string[next].isAZ() {
                retString += "} "
            } else {
                retString += "}"
            }
            return next
        }
        if addIndentBack {
            indent.count += 1
        }
        trimWithIndent()
        return add(char: char)
    }

    func removeUnnecessaryChar() {
        if autoRemoveChar && retString.last == ";" {
            retString = String(retString[..<retString.index(before: retString.endIndex)])
        }
    }

    func checkInCase() -> Bool {
        if indent.inCase {
            indent.inCase = false
            indent.leading -= 1
            indent.isLeading = false
            indent.count += 1
            return true
        }
        return false
    }

    func checkLine(_ char: Character, checkLast: Bool = true) -> String.Index {
        trim()
        newlineIndex = retString.count - 1
        if checkLast {
            checkLineEndExtra()
        } else {
            indent.extra = 0
        }
        indent.indentAdd = false
        indent.extraAdd = false
        strIndex = add(char: char)
        if !isNext(string: "//") {
            if isBetween(words: ("if", "let"), ("guard", "let")) {
                indent.extra = 1
            } else if isPrevious(str: "case") {
                indent.extra = 1
            } else if isNext(word: "else") {
                if retString.lastWord() != "}" {
                    indent.extra = 1
                }
            }
            addIndent()
        }
        return string.nextNonSpaceIndex(strIndex)
    }

    func checkDefault(char: Character) -> String.Index {
        strIndex = add(char: char)
        while strIndex < string.endIndex {
            let next = string[strIndex]
            if next.isAZ() {
                strIndex = add(char: next)
            } else {
                break
            }
        }
        return strIndex
    }

    func checkLineChar(char: Character) -> Int? {
        switch char {
        case "+", "-", "*", "=", ".", "&", "|":
            return 1
        case ":":
            if self.checkInCase() {
                return 0
            }
            if !self.indent.inSwitch {
                return 1
            }
        case ",":
            if self.indent.inEnum {
                return 0
            }
            if self.indent.line == 1 && (self.indent.block == .parentheses || self.indent.block == .square) {
                self.indent.isLeading = true
            }
            if self.indent.block == .curly {
                return 1
            }
        default:
            break
        }
        return nil
    }

    func checkLineEndExtra() {
        guard indent.block != .ifelse else {
            return
        }

        if let result = checkLineChar(char: retString.last) {
            indent.extra = result
            return
        }
        if strIndex < string.endIndex {
            let next = string.nextNonSpaceIndex(string.index(after: strIndex))
            if next < string.endIndex {
                if let result = checkLineChar(char: string[next]) {
                    indent.extra = result
                } else if string[next] == "?" {
                    indent.extra = 1
                } else {
                    indent.extra = 0
                }
            }
            // MARK: check next if ? :
        }
    }

}
