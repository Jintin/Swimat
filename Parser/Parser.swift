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

    func isBetween(words: (start: String, end: String, endLength: Int)...) -> Bool {
        // MARK: check word, not position
        if strIndex < string.endIndex {
            let startIndex = string.nextNonSpaceIndex(strIndex)
            for word in words {
                if let endIndex = string.index(startIndex, offsetBy: word.endLength, limitedBy: string.endIndex),
                    let _ = string.range(of: word.end, options: [], range: startIndex ..< endIndex) {
                    if retString.lastWord() == word.start { // MARK: cache last word
                        return true
                    }
                }
            }
        }
        return false
    }

    func isNext(word: String, length: Int) -> Bool {
        let index = string.nextNonSpaceIndex(strIndex)
        if let endIndex = string.index(index, offsetBy: length, limitedBy: string.endIndex),
            let _ = string.range(of: word, options: [], range: index ..< endIndex) {
            return true
        }
        return false
    }

    func isNext(words: (str: String, length: Int)...) -> Bool {
        let index = string.nextNonSpaceIndex(strIndex)
        for word in words {
            if let endIndex = string.index(index, offsetBy: word.length, limitedBy: string.endIndex),
                let _ = string.range(of: word.str, options: [], range: index ..< endIndex) {
                return true
            }
        }
        return false
    }

    // MARK: move to Entension.swift
    func isNext(string target: String, length: Int) -> Bool {
        if let endIndex = string.index(strIndex, offsetBy: length, limitedBy: string.endIndex),
            let _ = string.range(of: target, options: [], range: strIndex ..< endIndex) {
            return true
        }
        return false
    }

    func space(with word: String, length: Int) -> String.Index {
        if retString.last != "(" {
            retString.keepSpace()
        }
        retString += word + " "
        return string.nextNonSpaceIndex(string.index(strIndex, offsetBy: length))
    }

    func space(with words: [(str: String, length: Int)]) -> String.Index? {
        for word in words {
            if isNext(string: word.str, length: word.length) {
                return space(with: word.str, length: word.length)
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
            if isNext(word: "case", length: 4) {
                checkInCase = true
                indent.inCase = true
                indent.count -= 1
            } else if isNext(word: "default", length: 8) {
                indent.extra -= 1
            }
        }
        if isNext(word: "switch", length: 6) {
            isNextSwitch = true
        }
        let count = indent.count + (addExtra ? indent.extra : 0)
        if count > 0 {
            retString += String(repeating: Indent.char, count: count)
        }
        if indent.isLeading && indent.leading > 0 {
            retString += String(repeating: " ", count: indent.leading)
        }
        if checkInCase {
            indent.isLeading = true
            indent.leading += 1
        }
    }

    func add(string target: String, length: Int) -> String.Index {
        retString += target
        return string.index(strIndex, offsetBy: length)
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
