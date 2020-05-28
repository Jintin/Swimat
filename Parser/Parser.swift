import Foundation

extension SwiftParser {

    func isNext(char: Character, skipBlank: Bool = false) -> Bool {
        var next = string.index(after: strIndex)

        while next < string.endIndex {
            if skipBlank && string[next].isBlank() {
                next = string.index(after: next)
                continue
            }

            return string[next] == char
        }
        return false
    }

    func isPrevious(str: String) -> Bool {

        if let start = string.index(strIndex, offsetBy: -str.count, limitedBy: string.startIndex) {
            if let _ = string.range(of: str, options: [], range: start ..< strIndex) {
                return true
            }
        }
        return false
    }

    func isBetween(words: (start: String, end: String)...) -> Bool {
        // MARK: check word, not position
        if strIndex < string.endIndex {
            let startIndex = string.nextNonSpaceIndex(strIndex)
            for word in words {
                if let endIndex = string.index(startIndex, offsetBy: word.end.count, limitedBy: string.endIndex),
                    let _ = string.range(of: word.end, options: [], range: startIndex ..< endIndex) {
                    if retString.lastWord() == word.start { // MARK: cache last word
                        return true
                    }
                }
            }
        }
        return false
    }

    func isNext(word: String) -> Bool {
        let index = string.nextNonSpaceIndex(strIndex)
        if let endIndex = string.index(index, offsetBy: word.count, limitedBy: string.endIndex),
            let _ = string.range(of: word, options: [], range: index ..< endIndex) {
            return true
        }
        return false
    }

    // MARK: move to Entension.swift
    func isNext(string target: String) -> Bool {
        if let endIndex = string.index(strIndex, offsetBy: target.count, limitedBy: string.endIndex),
            let _ = string.range(of: target, options: [], range: strIndex ..< endIndex) {
            return true
        }
        return false
    }

    func space(with word: String) -> String.Index {
        if retString.last != "(" {
            retString.keepSpace()
        }
        retString += word + " "
        return string.nextNonSpaceIndex(string.index(strIndex, offsetBy: word.count))
    }

    func space(with words: [String]) -> String.Index? {
        for word in words {
            if isNext(string: word) {
                return space(with: word)
            }
        }
        return nil
    }

    func trim() {
        if retString.last.isSpace() {
            retString = retString.trim()
        }
    }

    func trimWithIndent(addExtra: Bool = true) {
        trim()
        if retString.last == "\n" {
            addIndent(addExtra: addExtra)
        }
    }

    func addIndent(addExtra: Bool = true) {
        var checkInCase = false
        if indent.inSwitch {
            if isNext(word: "case") {
                checkInCase = true
                indent.inCase = true
                indent.count -= 1
            } else if isNext(word: "default") || isNext(word: "@unknown") {
                indent.extra -= 1
            }
        }
        if isNext(word: "switch") {
            isNextSwitch = true
        } else if isNext(word: "enum") {
            isNextEnum = true
        }
        let count = indent.count + (addExtra ? indent.extra : 0)
        if count > 0 {
            retString += String(repeating: Indent.char, count: count)
        }
        indent.extra = 0
        if indent.isLeading && indent.leading > 0 {
            retString += String(repeating: " ", count: indent.leading)
        }
        if checkInCase {
            indent.isLeading = true
            indent.leading += 1
        }
    }

    func add(with words: [String]) -> String.Index? {
        for word in words {
            if isNext(string: word) {
                return add(string: word)
            }
        }
        return nil
    }

    func add(string target: String) -> String.Index {
        retString += target
        return string.index(strIndex, offsetBy: target.count)
    }

    func add(char: Character) -> String.Index {
        retString.append(char)
        return string.index(after: strIndex)
    }

    func addToNext(_ start: String.Index, stopWord: String) -> String.Index {
        if let result = string.range(of: stopWord, options: [], range: start ..< string.endIndex) {
            retString += string[start ..< result.upperBound]
            return result.upperBound
        }
        retString += string[start ..< string.endIndex]
        return string.endIndex
    }

    func addLine() -> String.Index {
        let start = strIndex
        var findNewLine = false

        if let result = string.range(of: "\n", options: [], range: start ..< string.endIndex) {
            findNewLine = true
            strIndex = result.lowerBound
        } else {
            strIndex = string.endIndex
        }
        retString += string[start ..< strIndex]
        if findNewLine {
            strIndex = checkLine("\n", checkLast: false)
        }
        return strIndex
    }

}
