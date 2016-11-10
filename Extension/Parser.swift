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

    func isBetween(_ texts: (start: String, end: String, endLength: Int)...) -> Bool { //TODO:check word, not position
        if strIndex < string.endIndex {
            let startIndex = string.nextNonSpaceIndex(strIndex)
            for text in texts {
                if let endIndex = string.index(startIndex, offsetBy: text.endLength, limitedBy: string.endIndex), let _ = string.range(of: text.end, options: [], range: startIndex ..< endIndex) {
                    if retString.lastWord() == text.start { //TODO: cache last word
                        return true
                    }
                }
            }
        }
        return false
    }

    func isNextWord(_ str: String, length: Int) -> Bool {
        let index = string.nextNonSpaceIndex(strIndex)
        if let endIndex = string.index(index, offsetBy: length, limitedBy: string.endIndex), let _ = string.range(of: str, options: [], range: index ..< endIndex) {
            return true
        }
        return false
    }

    func isNextWords(_ words: (str: String, length: Int)...) -> Bool {
        let index = string.nextNonSpaceIndex(strIndex)
        for word in words {
            if let endIndex = string.index(index, offsetBy: word.length, limitedBy: string.endIndex), let _ = string.range(of: word.str, options: [], range: index ..< endIndex) {
                return true
            }
        }
        return false
    }

    func isNextString(_ str: String, length: Int) -> Bool {
        if let endIndex = string.index(strIndex, offsetBy: length, limitedBy: string.endIndex), let _ = string.range(of: str, options: [], range: strIndex ..< endIndex) {
            return true
        }
        return false
    }

    func spaceWith(_ word: String, length: Int) -> String.Index {
        retString.keepSpace()
        retString += word + " "
        return string.nextNonSpaceIndex(string.index(strIndex, offsetBy: length))
    }

    func spaceWithArray(_ words: [StringObj]) -> String.Index? {
        for word in words {
            if isNextString(word.str, length: word.length) {
                return spaceWith(word.str, length: word.length)
            }
        }
        return nil
    }

    func trimWithIndent(ignoreTemp: Bool = false) {
        if retString.last.isSpace() {
            retString = retString.trim()
        }

        if retString.last == "\n" {
            addIndent(ignoreTemp: ignoreTemp)
        }
    }

    func addIndent(ignoreTemp: Bool = false) {
        if inSwitch {
            if isNextWords(("case", length: 4), ("default:", length: 8)) {
                tempIndent -= 1
            }
        } else if isNextWord("switch", length: 6) {
            inSwitch = true
        }

        retString += String(repeating: SwiftParser.indentChar, count: indent + (ignoreTemp ? 0 : tempIndent))

        if let block = blockStack.last {
            if !ignoreTemp {
//                retString += SwiftParser.indentChar
                retString += String(repeating: " ", count: block.indentCount)
            }
        }
    }

    func addString(_ string: String, length: Int) -> String.Index {
        retString += string
        return self.string.index(strIndex, offsetBy: length)
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
