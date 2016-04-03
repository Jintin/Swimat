import Foundation

class Parser {
	var string = ""
	var retString = ""
	var strIndex = "".startIndex
	var indent = 0
	var tempIndent = 0

	func isNext(string: String) -> Bool {
		return isNextFrom(strIndex, word: string)
	}

//	func isNextFrom(start: String.Index, word: Character) -> Bool {
//		if word != string[start] {
//			return false
//		}
//		return true
//	}

	func isNextFrom(start: String.Index, word: String) -> Bool {
		var index = start
		for char in word.characters {
			if char != string[index] {
				return false
			}
			index = index.successor()
		}
		return true
	}

	func spaceWith(word: String) -> String.Index {
		if !trimWithIndent() {
			retString += " "
		}
		append(word)
		retString += " "
		return string.nextNonSpaceIndex(strIndex)
	}

	func spaceWithArray(list: [String]) -> String.Index? {
		for word in list {
			if isNext(word) {
				return spaceWith(word)
			}
		}
		return nil
	}

	func trimWithIndent() -> Bool {
		if let last = retString.lastChar {
			if last.isSpace() {
				retString = retString.trim()
			}
		}
		if retString.lastChar == "\n" {
			return addIndent()
		}
		return false
	}

	func addIndent() -> Bool {
		// TODO repeat better alg
		for _ in 0 ..< indent + tempIndent {
			retString += "\t"
		}
		return indent + tempIndent > 0
	}

	func append(string: String) -> String.Index {
		retString += string
		strIndex = strIndex.advancedBy(string.count)
		return strIndex
	}

	func addToNext(start: String.Index, stopChar: String) -> String.Index {
		var index = start
		while index < string.endIndex {
			if isNextFrom(index, word: stopChar) {
				break
			}
			index = index.successor()
		}
		retString += string[start ..< index]
		return index
	}
}