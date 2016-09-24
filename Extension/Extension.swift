import Foundation

extension String {

    var count: Int {
        return characters.count
    }

    var lastChar: Character? {
        return characters.last
    }

    func lastWord() -> String {
        if count > 0 {
            let end = lastNonBlankIndex(index(before: endIndex))
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

    func nextStringIndex(_ start: String.Index, checker: (Character) -> Bool) -> String.Index {
        var index = start
        while index < endIndex {
            if checker(self[index]) {
                break
            }
            index = characters.index(after: index)
        }
        return index
    }

    func nextNonSpaceIndex(_ index: String.Index) -> String.Index {
        return nextStringIndex(index) { !$0.isSpace() }
    }

    func lastStringIndex(_ start: String.Index, checker: (Character) -> Bool) -> String.Index {
        var index = start
        while index > startIndex {
            if checker(self[index]) {
                break
            }
            index = characters.index(before: index)
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

    func findParentheses(_ start: String.Index) throws -> (string: String, index: String.Index) {
        return try findBlock(start, startSign: "(", endSign: ")")
    }

    func findSquare(_ start: String.Index) throws -> (string: String, index: String.Index) {
        return try findBlock(start, startSign: "[", endSign: "]")
    }

    func findBlock(_ start: String.Index, startSign: String, endSign: Character) throws -> (string: String, index: String.Index) {
        var index = characters.index(after: start)
        var result = startSign
        while index < endIndex {
            let next = self[index]

            if next == "\"" {
                let quote = try findQuote(index)
                index = quote.index
                result += quote.string
                continue
            } else if next == "(" {
                let block = try findParentheses(index)
                index = block.index
                result += block.string
                continue
            } else {
                result.append(next)
            }
            index = characters.index(after: index)
            if next == endSign {
                break
            }
        }
        // TODO: no need to new obj
        let obj = try SwiftParser(string: result).format()
        return (obj, index)
    }

    func findQuote(_ start: String.Index) throws -> (string: String, index: String.Index) {
        var escape = false
        var index = characters.index(after: start)
        var result = "\""
        while index < endIndex {
            let next = self[index]
            if next == "\n" {
                throw SwiftParser.FormatError.stringError
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

            index = characters.index(after: index)
            if !escape && next == "\"" {
                return (result, index)
            }
            if next == "\\" {
                escape = !escape
            } else {
                escape = false
            }
        }
        return (result, characters.index(before: endIndex))
    }

    func findTernary(_ index: String.Index) throws -> (string: String, index: String.Index)? {
        let start = nextNonSpaceIndex(characters.index(after: index))
        guard let first = try findObject(start) else {
            return nil
        }
        let middle = nextNonSpaceIndex(first.index)
        guard self[middle] == ":" else {
            return nil
        }
        let end = nextNonSpaceIndex(characters.index(after: middle))
        guard let second = try findObject(end) else {
            return nil
        }
        return ("? \(first.string) : \(second.string)", second.index)
    }

    func findObject(_ start: String.Index) throws -> (string: String, index: String.Index)? {
        var index = start
        var result = ""

        if self[index] == "-" {
            index = characters.index(after: index)
            result = "-"
        }

        while index < endIndex {
            let next = self[index]
            let list: [Character] = ["?", "!", "."]
            if next.isAZ() || list.contains(next) { // TODO: check complex case
                result.append(next)
            } else if next == "[" {
                let block = try findSquare(index)
                index = block.index
                result += block.string
                continue
            } else if next == "(" {
                let block = try findParentheses(index)
                index = block.index
                result += block.string
                continue
            } else if next == "\"" {
                let quote = try findQuote(index)
                index = quote.index
                result += quote.string
                continue
            } else {
                if result.isEmpty {
                    return nil
                }
                return (result, index)
            }
            index = characters.index(after: index)
        }
        return nil
    }

    func findGeneric(_ start: String.Index) throws -> (string: String, index: String.Index)? {
        var index = characters.index(after: start)
        var count = 1
        var result = "<"
        while index < endIndex {
            let next = self[index]

            switch next {
            case "A" ... "z", "0" ... "9", ",", " ", "[", "]", ".", "?", ":":
                result.append(next)
            case "<":
                count += 1
                result.append(next)
            case ">":
                count -= 1
                result.append(next)
                if count == 0 {
                    return (result, characters.index(after: index))
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

            index = characters.index(after: index)
        }
        return nil
    }

}

extension Character {

    func isAZ() -> Bool {
        switch self {
        case "A" ... "Z", "a" ... "z", "0" ... "9":
            return true
        default:
            return false
        }
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
