import Foundation

enum FormatError: Error {
    case stringError
}

struct StringObj {
    let str: String
    let length: Int

    init(str: String, length: Int) {
        self.str = str
        self.length = length
    }
}

fileprivate let OperatorList: [Character: [StringObj]] = [
    "+": [StringObj(str: "+=<", length: 3), StringObj(str: "+=", length: 2), StringObj(str: "+++=", length: 4), StringObj(str: "+++", length: 3), StringObj(str: "+", length: 1)],
    "-": [StringObj(str: "->", length: 2), StringObj(str: "-=", length: 2), StringObj(str: "-<<", length: 3)],
    "*": [StringObj(str: "*=", length: 2), StringObj(str: "*", length: 1)],
    "/": [StringObj(str: "/=", length: 2), StringObj(str: "/", length: 1)],
    "~": [StringObj(str: "~=", length: 2), StringObj(str: "~~>", length: 3), StringObj(str: "~>", length: 2)],
    "%": [StringObj(str: "%=", length: 2), StringObj(str: "%", length: 1)],
    "^": [StringObj(str: "^=", length: 2)],
    "&": [StringObj(str: "&&=", length: 3), StringObj(str: "&&&", length: 3), StringObj(str: "&&", length: 2), StringObj(str: "&=", length: 2), StringObj(str: "&+", length: 2), StringObj(str: "&-", length: 2), StringObj(str: "&*", length: 2), StringObj(str: "&/", length: 2), StringObj(str: "&%", length: 2)],
    "<": [StringObj(str: "<<<", length: 3), StringObj(str: "<<=", length: 3), StringObj(str: "<<", length: 2), StringObj(str: "<=", length: 2), StringObj(str: "<~~", length: 3), StringObj(str: "<~", length: 2), StringObj(str: "<--", length: 3), StringObj(str: "<-<", length: 3), StringObj(str: "<-", length: 2), StringObj(str: "<^>", length: 3), StringObj(str: "<|>", length: 3), StringObj(str: "<*>", length: 3), StringObj(str: "<||?", length: 4), StringObj(str: "<||", length: 3), StringObj(str: "<|?", length: 3), StringObj(str: "<|", length: 2), StringObj(str: "<", length: 1)],

    ">": [StringObj(str: ">>>", length: 3), StringObj(str: ">>=", length: 3), StringObj(str: ">>-", length: 3), StringObj(str: ">>", length: 2), StringObj(str: ">=", length: 2), StringObj(str: ">->", length: 3), StringObj(str: ">", length: 1)],
    "|": [StringObj(str: "|||", length: 3), StringObj(str: "||=", length: 3), StringObj(str: "||", length: 2), StringObj(str: "|=", length: 2), StringObj(str: "|", length: 1)],
    "!": [StringObj(str: "!==", length: 3), StringObj(str: "!=", length: 2)],

    "=": [StringObj(str: "===", length: 3), StringObj(str: "==", length: 2), StringObj(str: "=", length: 1)]
]
//fileprivate let OperatorList: [Character: [String]] = [
//    "+": ["+=<", "+=", "+++=", "+++", "+"],
//    "-": ["->", "-=", "-<<"],
//    "*": ["*=", "*"],
//    "/": ["/=", "/"],
//    "~": ["~=", "~~>", "~>"],
//    "%": ["%=", "%"],
//    "^": ["^="],
//    "&": ["&&=", "&&&", "&&", "&=", "&+", "&-", "&*", "&/", "&%"],
//    "<": ["<<<", "<<=", "<<", "<=", "<~~", "<~", "<--", "<-<", "<-", "<^>", "<|>", "<*>", "<||?", "<||", "<|?", "<|", "<"],
//    ">": [">>>", ">>=", ">>-", ">>", ">=", ">->", ">"],
//    "|": ["|||", "||=", "||", "|=", "|"],
//    "!": ["!==", "!="],
//    "=": ["===", "==", "="]
//]
fileprivate let NegativeCheckSigns: [Character] = ["+", "-", "*", "/", "&", "|", "^", "<", ">", ":", "(", "[", "{", "=", ",", ".", "?"]
fileprivate let NegativeCheckKeys = ["case", "return", "if", "for", "while", "in"]
fileprivate let Numbers: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

class SwiftParser {

    let string: String
    var retString = ""
    var strIndex: String.Index
    var indent = Indent()
    var indentStack = [Indent]()
    var newlineIndex: String.Index
    var isNextSwitch: Bool = false

    init(string: String) {
        self.string = string
        strIndex = string.startIndex
        newlineIndex = string.startIndex
    }

    func format() throws -> String {
        while strIndex < string.endIndex {
            let char = string[strIndex]
            strIndex = try checkChar(char)
        }
        return retString.trim()
    }

    func checkChar(_ char: Character) throws -> String.Index {
        switch char {
        case "+", "*", "%", ">", "|", "=":
            return spaceWithArray(OperatorList[char]!)!
        case "-":
            if let index = spaceWithArray(OperatorList[char]!) {
                return index
            } else {
                var noSpace = false
                if !retString.isEmpty {
                    // check scientific notation
                    if strIndex != string.endIndex {
                        if retString.last == "e" && Numbers.contains(string[string.index(after: strIndex)]) {
                            noSpace = true
                        }
                    }
                    // check negative
                    let last = retString.lastNonSpaceChar(retString.endIndex)
                    if last.isAZ() {
                        if NegativeCheckKeys.contains(retString.lastWord()) {
                            noSpace = true
                        }
                    } else {
                        if NegativeCheckSigns.contains(last) {
                            noSpace = true
                        }
                    }
                }
                if noSpace {
                    return addChar(char)
                }
                return spaceWith("-", length: 1)
            }
        case "~", "^", "!", "&":
            if let index = spaceWithArray(OperatorList[char]!) {
                return index
            }
            return addChar(char)
        case ".":
            if isNextChar(".") {
                if isNextString("...", length: 3) {
                    return addString("...", length: 3)
                } else if isNextString("..<", length: 3) {
                    return addString("..<", length: 3)
                }
            }
            return addChar(char)
        case "/":
            if isNextChar("/") {
                return addToLineEnd()
            } else if isNextChar("*") {
                return addToNext(strIndex, stopWord: "*/")
            }
            return spaceWithArray(OperatorList[char]!)!
        case "<":
            if isNextChar("#") {
                return addString("<#", length: 2)
            }
            if let result = try string.findGeneric(strIndex) {
                retString += result.string
                return result.index
            }
            return spaceWithArray(OperatorList[char]!)!
        case "?":
            if isNextChar("?") {
                // TODO: check double optional or nil check
                return addString("??", length: 2)
            } else if let ternary = try string.findTernary(strIndex) {
                retString.keepSpace()
                retString += ternary.string
                return ternary.index
            } else {
                return addChar(char)
            }
        case ":":
            trimWithIndent()
            retString += ": "
            return string.nextNonSpaceIndex(string.index(after: strIndex))
        case "#":
            if isNextString("#if", length: 3) {
                indent.count += 1
                return addToLineEnd() //TODO: bypass like '#if swift(>=3)'
            } else if isNextString("#else", length: 5) {
                indent.count -= 1
                trimWithIndent()
                indent.count += 1
                return addToLineEnd() //bypass like '#if swift(>=3)'
            } else if isNextString("#endif", length: 6) {
                indent.count -= 1
                trimWithIndent()
                return addToLineEnd() //bypass like '#if swift(>=3)'
            } else if isNextChar(">") {
                return addString("#>", length: 2)
            } else if isNextChar("!") {
                return addToLineEnd()
            }
            break
        case "\"":
            let quote = try string.findQuote(strIndex)
            retString += quote.string
            return quote.index
        case "\n":
            return checkLine(char)
        case " ", "\t":
            retString.keepSpace()
            return string.index(after: strIndex)
        case ",":
            trimWithIndent()
            retString += ", "
            return string.nextNonSpaceIndex(string.index(after: strIndex))
        case "{", "[", "(":
            indentStack.append(indent)
            let leading = retString.distance(from: newlineIndex, to: retString.endIndex)
            indent = Indent(with: indent, offset: leading, type: IndentType(rawValue: char))

            if indent.block == .curly {
                if isNextSwitch {
                    indent.inSwitch = true
                    isNextSwitch = false
                }
                if !retString.last.isUpperBlock() {
                    retString.keepSpace()
                }

                retString += "{ "
                return string.index(after: strIndex)
            } else {
                return addChar(char)
            }
        case "}", "]", ")":
            if let last = indentStack.popLast() {
                indent = last
            } else {
                indent = Indent()
            }
            if char == "}" {
                trimWithIndent(ignoreTemp: true) // TODO: change to newline check
                retString.keepSpace()
                let next = string.index(after: strIndex)
                if next < string.endIndex && string[next].isAZ() {
                    retString += "} "
                } else {
                    retString += "}"
                }
                return next
            } else {
                trimWithIndent()
                return addChar(char)
            }
        default:
            return checkDefault(char)
        }
        return checkDefault(char)
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
        strIndex = addChar(char)
        if !isNextString("//", length: 2) {
            addIndent()
            if isBetween(("if", "let", 3), ("guard", "let", 3)) {
                retString += Indent.char
            } else if isNextWord("else", length: 4) {
                retString += Indent.char
            }
        }
        return string.nextNonSpaceIndex(strIndex)
    }

    func checkDefault(_ char: Character) -> String.Index {
        strIndex = addChar(char)
        while strIndex < string.endIndex {
            let next = string[strIndex]
            if next.isAZ() {
                strIndex = addChar(next)
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
            case "+", "-", "*", "=", ".":
                return 1
            case "/": // TODO: check word, nor char
                break
            case ":":
                if !self.indent.inSwitch {
                    return 1
                }
            case ",":
                if self.indent.block == .curly {
                    return 1
                }
            default:
                break
            }
            return nil
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
            // TODO: check next if ? :
        }
    }

}
