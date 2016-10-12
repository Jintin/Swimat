import Foundation

extension String {

    var last: Character {
        return characters.last ?? "\0" as Character
    }

    func lastWord() -> String {
        if !isEmpty {
            let end = lastNonBlankIndex(endIndex)
            if end != startIndex || !self[end].isBlank() {
                let start = lastStringIndex(end) { $0.isBlank() }
                if self[start].isBlank() {
                    return self[index(after: start) ... end]
                }
                return self[start ... end]
            }
        }
        return ""
    }

    func trim() -> String {
        return trimmingCharacters(in: .whitespaces)
    }

    mutating func keepSpace() {
        if !last.isBlank() {
            append(" ")
        }
    }

    func nextStringIndex(_ start: String.Index, checker: (Character) -> Bool) -> String.Index {
        var index = start
        while index < endIndex {
            if checker(self[index]) {
                break
            }
            index = self.index(after: index)
        }
        return index
    }

    func nextNonSpaceIndex(_ index: String.Index) -> String.Index {
        return nextStringIndex(index) { !$0.isSpace() }
    }

    func lastStringIndex(_ start: String.Index, checker: (Character) -> Bool) -> String.Index {
        var index = start
        while index > startIndex {
            index = self.index(before: index)
            if checker(self[index]) {
                break
            }
        }
        return index
    }

    func lastNonSpaceIndex(_ start: String.Index) -> String.Index {
        return lastStringIndex(start) { !$0.isSpace() }
    }

    func lastNonSpaceChar(_ start: String.Index) -> Character {
        return self[lastNonSpaceIndex(start)]
    }

    func lastNonBlankIndex(_ start: String.Index) -> String.Index {
        return lastStringIndex(start) { !$0.isBlank() }
    }

}

extension String {

    func findParentheses(_ start: String.Index, needFormat: Bool = true) throws -> (string: String, index: String.Index) {
        return try findBlock(start, startSign: "(", endSign: ")", needFormat: needFormat)
    }

    func findSquare(_ start: String.Index, needFormat: Bool = true) throws -> (string: String, index: String.Index) {
        return try findBlock(start, startSign: "[", endSign: "]", needFormat: needFormat)
    }

    func findBlock(_ start: String.Index, startSign: String, endSign: Character, needFormat: Bool) throws -> (string: String, index: String.Index) {
        var index = self.index(after: start)
        var result = startSign
        while index < endIndex {
            let next = self[index]

            if next == "\"" {
                let quote = try findQuote(index)
                index = quote.index
                result += quote.string
                continue
            } else if next == "(" {
                let block = try findParentheses(index, needFormat: false)
                index = block.index
                result += block.string
                continue
            } else {
                result.append(next)
            }
            index = self.index(after: index)
            if next == endSign {
                break
            }
        }
        // TODO: no need to new obj
        if needFormat {
            let obj = try SwiftParser(string: result).format()
            return (obj, index)
        } else {
            return (result, index)
        }
    }

    func findQuote(_ start: String.Index) throws -> (string: String, index: String.Index) {
        var escape = false
        var index = self.index(after: start)
        var result = "\""
        while index < endIndex {
            let next = self[index]
            if next == "\n" {
                throw FormatError.stringError
            }

            if escape && next == "(" {
                let block = try findParentheses(index)
                index = block.index
                result += block.string

                escape = false
                continue
            } else {
                result.append(next)
            }

            index = self.index(after: index)
            if !escape && next == "\"" {
                return (result, index)
            }
            if next == "\\" {
                escape = !escape
            } else {
                escape = false
            }
        }
        return (result, self.index(before: endIndex))
    }

    func findTernary(_ index: String.Index) throws -> (string: String, index: String.Index)? {
        let start = nextNonSpaceIndex(self.index(after: index))
        guard let first = try findObject(start) else {
            return nil
        }
        let middle = nextNonSpaceIndex(first.index)
        guard self[middle] == ":" else {
            return nil
        }
        let end = nextNonSpaceIndex(self.index(after: middle))
        guard let second = try findObject(end) else {
            return nil
        }
        return ("? " + first.string + " : " + second.string, second.index)
    }


    func findObject(_ start: String.Index) throws -> (string: String, index: String.Index)? {
        var index = start
        var result = ""

        if self[index] == "-" {
            index = self.index(after: index)
            result = "-"
        }
        let list: [Character] = ["?", "!", "."]
        while index < endIndex {
            let next = self[index]
            if next.isAZ() || list.contains(next) { // TODO: check complex case
                result.append(next)
                index = self.index(after: index)
            } else if next == "[" {
                let block = try findSquare(index)
                index = block.index
                result += block.string
            } else if next == "(" {
                let block = try findParentheses(index)
                index = block.index
                result += block.string
            } else if next == "\"" {
                let quote = try findQuote(index)
                index = quote.index
                result += quote.string
            } else {
                break
            }
        }
        if result.isEmpty {
            return nil
        }
        return (result, index)
    }

    func findGeneric(_ start: String.Index) throws -> (string: String, index: String.Index)? {
        var index = self.index(after: start)
        var count = 1
        var result = "<"
        while index < endIndex {
            let next = self[index]

            switch next {
            case "A" ... "z", "0" ... "9", " ", "[", "]", ".", "?", ":":
                result.append(next)
            case ",":
                result.append(", ")
                index = nextNonSpaceIndex(self.index(after: index))
                continue
            case "<":
                count += 1
                result.append(next)
            case ">":
                count -= 1
                result.append(next)
                if count == 0 {
                    return (result, self.index(after: index))
                } else if count < 0 {
                    return nil
                }
            case "\"":
                let quote = try findQuote(index)
                index = quote.index
                result += quote.string
                continue
            case "(":
                let block = try findParentheses(index)
                index = block.index
                result += block.string
                continue
            default:
                return nil
            }

            index = self.index(after: index)
        }
        return nil
    }

}

extension Character {

    func isAZ() -> Bool {
//        [0.009290, 0.000007, 0.000006, 0.000006, 0.000006, 0.000007, 0.000006, 0.000006, 0.000006, 0.000006],
//        switch self {
//        case "A" ... "Z", "a" ... "z", "0" ... "9":
//            return true
//        default:
//            return false
//        }
//        [0.007204, 0.000005, 0.000003, 0.000003, 0.000003, 0.000003, 0.000003, 0.000003, 0.000003, 0.000003]
        if self >= "a" && self <= "z" {
            return true
        } else if self >= "A" && self <= "Z" {
            return true
        } else if self >= "0" && self <= "9" {
            return true
        }
        return false
    }

    func isOperator() -> Bool {
        return self == "+" || self == "-" || self == "*" || self == "/"
    }

    func isUpperBlock() -> Bool {
        return self == "{" || self == "[" || self == "("
    }

    func isLowerBlock() -> Bool {
        return self == "}" || self == "]" || self == ")"
    }

    func isSpace() -> Bool {
        return self == " " || self == "\t"
    }

    func isBlank() -> Bool {
        return isSpace() || self == "\n"
    }

}
