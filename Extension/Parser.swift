import Foundation

extension SwiftParser {

    func isNextChar(_ char: Character) -> Bool {
        let next = string.index(after: strIndex)

        if next < string.endIndex {
            return string[next] == char
        } else {
            return false
        }
    }

    func isBetween(_ texts: (first: String, last: String)...) -> Bool { //TODO:check word, not position
        if strIndex < string.endIndex {
            let last = retString.lastWord()
            let startIndex = string.nextNonSpaceIndex(strIndex)
            for text in texts {
                if let endIndex = string.index(startIndex, offsetBy: text.last.count, limitedBy: string.endIndex), let _ = string.range(of: text.last, options: [], range: startIndex ..< endIndex) {
                    if last == text.first {
                        return true
                    }
                }
            }
        }
        return false
    }

    func isNextString(_ string: String) -> Bool {
        return isNextString(strIndex, word: string)
    }

    func isNextWords(_ words: String...) -> Bool {
        let start = string.nextNonSpaceIndex(strIndex)
        for text in words {
            if let endIndex = string.index(start, offsetBy: text.count, limitedBy: string.endIndex), let _ = string.range(of: text, options: [], range: start ..< endIndex) {
                    return true
            }
        }
        return false
    }

    func isNextWord(_ word: String) -> Bool {
        let index = string.nextNonSpaceIndex(strIndex)
        return isNextString(index, word: word)
    }

    func isNextString(_ start: String.Index, word: String...) -> Bool {
        for text in word {
            if let endIndex = string.index(start, offsetBy: text.count, limitedBy: string.endIndex), let _ = string.range(of: text, options: [], range: start ..< endIndex) {
                return true
            }
        }
        return false
    }

    func spaceWith(_ word: String) -> String.Index {
        retString.keepSpace()
        retString += "\(word) "
        return string.nextNonSpaceIndex(string.index(strIndex, offsetBy: word.count))
    }

    func spaceWithArray(_ list: [String]) -> String.Index? {
        for word in list {
            if isNextString(word) {
                return spaceWith(word)
            }
        }
        return nil
    }

    func trimWithIndent(ignoreTemp: Bool = false) {
        retString = retString.trim()

        if retString.last == "\n" {
            addIndent(ignoreTemp: ignoreTemp)
        }
    }

    func addIndent(ignoreTemp: Bool = false) {
        if inSwitch {
            if isNextWords("case", "default:") {
                tempIndent -= 1
            }
        } else if isNextWord("switch") {
            inSwitch = true
        }

        retString += String(repeating: SwiftParser.indentChar, count: indent + (ignoreTemp ? 0 : tempIndent))

        if let block = blockStack.last {
            if !ignoreTemp && blockType == .parentheses {
//                retString += SwiftParser.indentChar
                retString += String(repeating: " ", count: block.indentCount)
            }
        }
    }

    func addString(_ string: String) -> String.Index {
        retString += string
        return self.string.index(strIndex, offsetBy: string.count)
    }

    func addChar(_ char: Character) -> String.Index {
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

    func addToLineEnd() -> String.Index {
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
