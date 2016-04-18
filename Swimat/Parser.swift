import Foundation

extension SwiftParser {
	func isNextChar(char: Character) -> Bool {
		let next = strIndex.successor()
		if next < string.endIndex {
			return string[next] == char
		} else {
			return false
		}
	}

	func isNextString(string: String) -> Bool {
		return isNextString(strIndex, word: string)
	}

	func isNextWord(word: String) -> Bool {
		let index = string.nextNonSpaceIndex(strIndex)
		return isNextString(index, word: word)
	}

	func isNextString(start: String.Index, word: String) -> Bool {
		return string.substringFromIndex(start).hasPrefix(word)
	}
	
	func keepSpace() {
		if let last = retString.lastChar where !last.isBlank() {
			retString += " "
		}
	}

	func spaceWith(word: String = "") -> String.Index {
		keepSpace()
		retString += "\(word) "
		return string.nextNonSpaceIndex(strIndex.advancedBy(word.count))
	}

	func spaceWithArray(list: [String]) -> String.Index? {
		for word in list {
			if isNextString(word) {
				return spaceWith(word)
			}
		}
		return nil
	}

	func trimWithIndent() {
		retString = retString.trim()

		if retString.lastChar == "\n" {
			addIndent()
		}
	}

	func addIndent() {
		if inSwitch {
			if isNextWord("case") || isNextWord("default:") {
				tempIndent -= 1
			}
		} else if isNextWord("switch") {
			inSwitch = true
		}
		retString += String(count: indent + tempIndent, repeatedValue: INDENT_CHAR)
	}

	func append(string: String) -> String.Index {
		retString += string
		strIndex = strIndex.advancedBy(string.count)
		return strIndex
	}

	func append(char: Character) -> String.Index {
		retString.append(char)
		strIndex = strIndex.successor()
		return strIndex
	}

	func addToNext(start: String.Index, stopWord: String) -> String.Index {
		var index = start
		while index < string.endIndex {
			if isNextString(index, word: stopWord) {
				break
			}
			index = index.successor()
		}
		retString += string[start ..< index]
		return index
	}

	func addToNext(start: String.Index, stopChar: Character) -> String.Index {
		var index = start
		while index < string.endIndex {
			if string[index] == stopChar {
				break
			}
			index = index.successor()
		}
		retString += string[start ..< index]
		return index
	}
}