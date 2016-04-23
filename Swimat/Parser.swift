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

	func spaceWith(word: String) -> String.Index {
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
		for _ in 0 ..< indent + tempIndent {
			retString += indentChar
		}
	}

	func addString(string: String) -> String.Index {
		retString += string
		return strIndex.advancedBy(string.count)
	}

	func addChar(char: Character) -> String.Index {
		retString.append(char)
		return strIndex.successor()
	}

	func addToNext(start: String.Index, stopWord: String) -> String.Index {
		var index = start
		while index < string.endIndex {
			if isNextString(index, word: stopWord) {
				index = index.advancedBy(stopWord.count)
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
				index = index.successor()
				break
			}
			index = index.successor()
		}
		retString += string[start ..< index]
		return index
	}

}
