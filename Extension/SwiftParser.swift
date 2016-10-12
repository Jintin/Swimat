import Foundation

enum BlockType: Character {
    case parentheses = "(", square = "[", curly = "{"
}

struct Block {
    let indent: Int
    let tempIndent: Int
    let indentCount: Int
    let type: BlockType
}

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

    static var indentChar: String = ""
    static var indentSize: Int = 0
    let string: String
    var retString = ""
    var strIndex: String.Index
    var blockStack = [Block]()
    var blockType: BlockType = .curly
    var indent = 0
    var tempIndent = 0
    var inSwitch = false
    var switchCount = 0
    var newlineIndex: String.Index

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
            if retString.last.isSpace() {
                trimWithIndent()
            }
            retString += ": "
            return string.nextNonSpaceIndex(string.index(after: strIndex))
        case "#":
            if isNextString("#if", length: 3) {
                indent += 1
                return addToLineEnd() //TODO: bypass like '#if swift(>=3)'
            } else if isNextString("#else", length: 5) {
                indent -= 1
                trimWithIndent()
                indent += 1
                return addToLineEnd() //bypass like '#if swift(>=3)'
            } else if isNextString("#endif", length: 6) {
                indent -= 1
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
            if retString.last.isSpace() {
                trimWithIndent()
            }
            retString += ", "
            return string.nextNonSpaceIndex(string.index(after: strIndex))
        case "{", "[", "(":
            let count = retString.distance(from: newlineIndex, to: retString.endIndex) - (indent + tempIndent) * SwiftParser.indentSize - 1
            let block = Block(indent: indent, tempIndent: tempIndent, indentCount: count, type: blockType)
            blockStack.append(block)
            blockType = BlockType(rawValue: char) ?? .curly
            if blockType == .parentheses {
                indent += tempIndent
            } else {
                indent += tempIndent + 1
            }
            if inSwitch && char == "{" {
                switchCount += 1
            }
            if char == "{" {
                if !retString.last.isUpperBlock() {
                    retString.keepSpace()
                }

                retString += "{ "
                return string.index(after: strIndex)
            } else {
                return addChar(char)
            }
        case "}", "]", ")":
            if let block = blockStack.popLast() {
                indent = block.indent
                tempIndent = block.tempIndent
                blockType = block.type
            } else {
                indent = 0
                tempIndent = 0
                blockType = .curly
            }
            if inSwitch && char == "}" {
                switchCount -= 1
                if switchCount == 0 {
                    inSwitch = false
                }
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
        if retString.last.isSpace() {
            retString = retString.trim()
        }
        newlineIndex = retString.endIndex
        if checkLast {
            checkLineEnd()
        } else {
            tempIndent = 0
        }
        strIndex = addChar(char)
        if !isNextString("//", length: 2) {
            addIndent()
            if isBetween(("if", "let", 3), ("guard", "let", 3)) {
                retString += SwiftParser.indentChar
            } else if isNextWord("else", length: 4) {
                retString += SwiftParser.indentChar
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
                if !self.inSwitch {
                    return 1
                }
            case ",":
                if self.blockType == .curly {
                    return 1
                }
            default:
                break
            }
            return nil
        }

        if let result = check(retString.last) {
            tempIndent = result
            return
        }

        if strIndex < string.endIndex {
            let next = string.nextNonSpaceIndex(string.index(after: strIndex))
            if next < string.endIndex {
                if let result = check(string[next]) {
                    tempIndent = result
                    return
                }
                if string[next] == "?" {
                    tempIndent = 1
                    return
                }
            }
            tempIndent = 0
            // TODO: check next if ? :
        }
    }

}
