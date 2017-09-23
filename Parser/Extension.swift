import Foundation

extension String {

    var last: Character {
        return characters.last ?? "\0" as Character
    }

    func lastWord() -> String {
        if !isEmpty {
            let end = lastNonBlankIndex(endIndex)
            if end != startIndex || !self[end].isBlank() {
                let start = lastIndex(from: end) { $0.isBlank() }
                if self[start].isBlank() {
                    return String(self[index(after: start) ... end])
                }
                return String(self[start ... end])
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

    func nextIndex(from start: String.Index, checker: (Character) -> Bool) -> String.Index {
        var target = start
        while target < endIndex {
            if checker(self[target]) {
                break
            }
            target = index(after: target)
        }
        return target
    }

    func nextNonSpaceIndex(_ index: String.Index) -> String.Index {
        return nextIndex(from: index) { !$0.isSpace() }
    }

    func lastIndex(from: String.Index, checker: (Character) -> Bool) -> String.Index {
        var target = from
        while target > startIndex {
            target = index(before: target)
            if checker(self[target]) {
                break
            }
        }
        return target
    }

    func lastNonSpaceIndex(_ start: String.Index) -> String.Index {
        return lastIndex(from: start) { !$0.isSpace() }
    }

    func lastNonSpaceChar(_ start: String.Index) -> Character {
        return self[lastNonSpaceIndex(start)]
    }

    func lastNonBlankIndex(_ start: String.Index) -> String.Index {
        return lastIndex(from: start) { !$0.isBlank() }
    }

}

extension String {

    typealias StringObj = (string: String, index: String.Index)

    func findParentheses(from start: String.Index, reFormat: Bool = true) throws -> StringObj {
        return try findBlock(type: .parentheses, from: start, reFormat: reFormat)
    }

    func findSquare(from start: String.Index, reFormat: Bool = true) throws -> StringObj {
        return try findBlock(type: .square, from: start, reFormat: reFormat)
    }

    func findBlock(type: IndentType, from start: String.Index, reFormat: Bool) throws -> StringObj {
        var target = index(after: start)
        var result = String(type.rawValue)
        while target < endIndex {
            let next = self[target]

            if next == "\"" {
                let quote = try findQuote(from: target)
                target = quote.index
                result += quote.string
                continue
            } else if next == "(" {
                let block = try findParentheses(from: target, reFormat: false)
                target = block.index
                result += block.string
                continue
            } else {
                result.append(next)
            }
            target = index(after: target)
            if next == type.stopSymbol() {
                break
            }
        }
        // MARK: no need to new obj
        if reFormat {
            let obj = try SwiftParser(string: result).format()
            return (obj, target)
        } else {
            return (result, target)
        }
    }

    func findQuote(from start: String.Index) throws -> StringObj {
        var escape = false
        var target = index(after: start)
        var result = "\""
        while target < endIndex {
            let next = self[target]
            if next == "\n" {
                throw FormatError.stringError
            }

            if escape && next == "(" {
                let block = try findParentheses(from: target)
                target = block.index
                result += block.string

                escape = false
                continue
            } else {
                result.append(next)
            }

            target = index(after: target)
            if !escape && next == "\"" {
                return (result, target)
            }
            if next == "\\" {
                escape = !escape
            } else {
                escape = false
            }
        }
        return (result, index(before: endIndex))
    }

    func findTernary(from target: String.Index) throws -> StringObj? {
        let start = nextNonSpaceIndex(index(after: target))
        guard let first = try findStatement(from: start) else {
            return nil
        }
        let middle = nextNonSpaceIndex(first.index)
        guard middle < endIndex, self[middle] == ":" else {
            return nil
        }
        let end = nextNonSpaceIndex(index(after: middle))
        guard let second = try findObject(from: end) else {
            return nil
        }
        return ("? " + first.string + " : " + second.string, second.index)
    }

    func findStatement(from start: String.Index) throws -> StringObj? {
        if let obj1 = try findObject(from: start) {
            let operIndex = nextNonSpaceIndex(obj1.index)
            guard operIndex < endIndex, self[operIndex].isOperator() else {
                return obj1
            }
            let list = operatorList[self[operIndex]]
            for compare in list! {
                if isNext(string: compare.0, length: compare.1, strIndex: operIndex) {
                    let operEnd = index(operIndex, offsetBy: compare.1)
                    let obj2Index = nextNonSpaceIndex(operEnd)
                    if let obj2 = try findObject(from: obj2Index) {
                        return (string: obj1.string + " " + compare.0 + " " + obj2.string, index: obj2.index)
                    } else {
                        return obj1
                    }
                }
            }
            return obj1
        }
        return nil
    }

    func findObject(from start: String.Index) throws -> StringObj? {
        guard start < endIndex else {
            return nil
        }
        var target = start
        var result = ""

        if self[target] == "-" {
            target = index(after: target)
            result = "-"
        }
        let list: [Character] = ["?", "!", "."]
        while target < endIndex {
            let next = self[target]
            if next.isAZ() || list.contains(next) { // MARK: check complex case
                result.append(next)
                target = index(after: target)
            } else if next == "[" {
                let block = try findSquare(from: target)
                target = block.index
                result += block.string
            } else if next == "(" {
                let block = try findParentheses(from: target)
                target = block.index
                result += block.string
            } else if next == "\"" {
                let quote = try findQuote(from: target)
                target = quote.index
                result += quote.string
            } else {
                break
            }
        }
        if result.isEmpty {
            return nil
        }
        return (result, target)
    }

    func findGeneric(from start: String.Index) throws -> StringObj? {
        var target = index(after: start)
        var count = 1
        var result = "<"
        while target < endIndex {
            let next = self[target]
            switch next {
            case " ":
                result.keepSpace()
            case "A" ... "z", "0" ... "9", "[", "]", ".", "?", ":":
                result.append(next)
            case ",":
                result.append(", ")
                target = nextNonSpaceIndex(index(after: target))
                continue
            case "<":
                count += 1
                result.append(next)
            case ">":
                count -= 1
                result.append(next)
                if count == 0 {
                    return (result, index(after: target))
                } else if count < 0 {
                    return nil
                }
            case "\"":
                let quote = try findQuote(from: target)
                target = quote.index
                result += quote.string
                continue
            case "(":
                let block = try findParentheses(from: target)
                target = block.index
                result += block.string
                continue
            case "-":
                if isNext(string: "->", length: 2, strIndex: target) {
                    result.keepSpace()
                    result.append("-> ")
                    target = index(target, offsetBy: 2)
                    continue
                }
                return nil
            default:
                return nil
            }

            target = index(after: target)
        }
        return nil
    }

    // MARK: remove duplicate in Parser.swift
    func isNext(string target: String, length: Int, strIndex: String.Index) -> Bool {
        if let stopIndex = self.index(strIndex, offsetBy: length, limitedBy: endIndex),
            let _ = self.range(of: target, options: [], range: strIndex ..< stopIndex) {
            return true
        }
        return false
    }

}

extension Character {

    func isAZ() -> Bool {
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
        return self == "+" || self == "-" || self == "*" || self == "/" || self == "%"
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
