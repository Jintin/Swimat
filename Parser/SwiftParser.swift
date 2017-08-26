import Foundation

enum FormatError: Error {
    case stringError
}

let operatorList: [Character: [(String, Int)]] =
    [
        "+": [("+=<", 3), ("+=", 2), ("+++=", 4), ("+++", 3), ("+", 1)],
        "-": [("->", 2), ("-=", 2), ("-<<", 3)],
        "*": [("*=", 2), ("*", 1)],
        "/": [("/=", 2), ("/", 1)],
        "~": [("~=", 2), ("~~>", 3), ("~>", 2)],
        "%": [("%=", 2), ("%", 1)],
        "^": [("^=", 2)],
        "&": [("&&=", 3), ("&&&", 3), ("&&", 2), ("&=", 2), ("&+", 2),
            ("&-", 2), ("&*", 2), ("&/", 2), ("&%", 2)],
        "<": [("<<<", 3), ("<<=", 3), ("<<", 2), ("<=", 2), ("<~~", 3),
            ("<~", 2), ("<--", 3), ("<-<", 3), ("<-", 2), ("<^>", 3),
            ("<|>", 3), ("<*>", 3), ("<||?", 4), ("<||", 3), ("<|?", 3),
            ("<|", 2), ("<", 1)],
        ">": [(">>>", 3), (">>=", 3), (">>-", 3), (">>", 2), (">=", 2),
            (">->", 3), (">", 1)],
        "|": [("|||", 3), ("||=", 3), ("||", 2), ("|=", 2), ("|", 1)],
        "!": [("!==", 3), ("!=", 2)],
        "=": [("===", 3), ("==", 2), ("=", 1)],
        "?": []
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
    var newlineIndex: String.Index
    var isNextSwitch: Bool = false
    var autoRemoveChar: Bool = false

    init(string: String) {
        self.string = string
        self.strIndex = string.startIndex
        self.newlineIndex = string.startIndex
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
        case "-":
            return checkMinus(char: char)
        case ".":
            if isNext(char: ".") {
                if isNext(string: "...", length: 3) {
                    return add(string: "...", length: 3)
                } else if isNext(string: "..<", length: 3) {
                    return add(string: "..<", length: 3)
                }
            }
            return add(char: char)
        case "/":
            if isNext(char: "/") {
                return addLine()
            } else if isNext(char: "*") {
                return addToNext(strIndex, stopWord: "*/")
            }
            return space(with: operatorList[char]!)!
        case "<":
            if isNext(char: "#") {
                return add(string: "<#", length: 2)
            }
            if let result = try string.findGeneric(from: strIndex) {
                retString += result.string
                return result.index
            }
            return space(with: operatorList[char]!)!
        case "?":
            if let spaceChar = operatorList[char] {
                if let index = space(with: spaceChar) {
                    return index
                }
            }

            if isNext(char: "?") {
                // MARK: check double optional or nil check
                return add(string: "??", length: 2)
            } else if let ternary = try string.findTernary(from: strIndex) {
                retString.keepSpace()
                retString += ternary.string
                return ternary.index
            } else {
                return add(char: char)
            }
        case ":":
            _ = checkInCase()
            trimWithIndent()
            retString += ": "
            return string.nextNonSpaceIndex(string.index(after: strIndex))
        case "#":
            if isNext(string: "#if", length: 3) {
                indent.count += 1
                return addLine() // MARK: bypass like '#if swift(>=3)'
            } else if isNext(string: "#else", length: 5) {
                indent.count -= 1
                trimWithIndent()
                indent.count += 1
                return addLine() //bypass like '#if swift(>=3)'
            } else if isNext(string: "#endif", length: 6) {
                indent.count -= 1
                trimWithIndent()
                return addLine() //bypass like '#if swift(>=3)'
            } else if isNext(char: ">") {
                return add(string: "#>", length: 2)
            } else if isNext(char: "!") {
                return addLine()
            }
            break
        case "\"":
            if isNext(string: "\"\"\"", length: 3) {
                strIndex = add(string: "\"\"\"", length: 3)
                return addToNext(strIndex, stopWord: "\"\"\"")
            }
            let quote = try string.findQuote(from: strIndex)
            retString += quote.string
            return quote.index
        case "\n":
            removeUnnecessaryChar()
            indent.line += 1
            return checkLine(char)
        case " ", "\t":
            if retString.lastWord() == "if" {
                let leading = retString.distance(from: newlineIndex, to: retString.endIndex)
                let newIndent = Indent(with: indent, offset: leading, type: IndentType(rawValue: "f"))
                indentStack.append(indent)
                indent = newIndent
            }
            retString.keepSpace()
            return string.index(after: strIndex)
        case ",":
            trimWithIndent()
            retString += ", "
            return string.nextNonSpaceIndex(string.index(after: strIndex))
        case "{", "[", "(":
            if char == "{" && indent.block == .ifelse {
                if let last = indentStack.popLast() {
                    indent = last
                    if indent.indentAdd {
                        indent.indentAdd = false
                    }
                }
            }
            let offset = retString.distance(from: newlineIndex, to: retString.endIndex)
            let newIndent = Indent(with: indent, offset: offset, type: IndentType(rawValue: char))
            indentStack.append(indent)
            indent = newIndent
            if indent.block == .curly {
                if isNextSwitch {
                    indent.inSwitch = true
                    isNextSwitch = false
                }
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
        case "}", "]", ")":
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
        default:
            break
        }
        return checkDefault(char: char)
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
            return space(with: "-", length: 1)
        }
    }

    func removeUnnecessaryChar() {
        if autoRemoveChar && retString.last == ";" {
            retString = retString.substring(to: retString.index(before: retString.endIndex))
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
        newlineIndex = retString.endIndex
        if checkLast {
            checkLineEnd()
        } else {
            indent.extra = 0
        }
        indent.indentAdd = false
        indent.extraAdd = false
        strIndex = add(char: char)
        if !isNext(string: "//", length: 2) {
            if isBetween(words: ("if", "let", 3), ("guard", "let", 3)) {
                indent.extra = 1
            } else if isNext(word: "else", length: 4) {
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

    func checkLineEnd() {
        let check = {
            (char: Character) -> Int? in
            switch char {
            case "+", "-", "*", "=", ".", "&", "|":
                return 1
            case "/": // MARK: check word, nor char
                break
            case ":":
                if self.checkInCase() {
                    return 0
                }
                if !self.indent.inSwitch {
                    return 1
                }
            case ",":
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

        if indent.block == .ifelse {
            return
        }

        if let result = check(retString.last) {
            indent.extra = result
            return
        }

        if strIndex < string.endIndex {
            let next = string.nextNonSpaceIndex(string.index(after: strIndex))
            if next < string.endIndex {
                if let result = check(string[next]) {
                    indent.extra = result
                    return
                }
                if string[next] == "?" {
                    indent.extra = 1
                    return
                }
            }
            indent.extra = 0
            // MARK: check next if ? :
        }
    }

}
