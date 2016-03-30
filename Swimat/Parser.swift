import Foundation

class Parser {
	var string = ""
	var retString = ""
	var strIndex = 0
	var indent = 0
	var tempIndent = 0

	func isNext(char: String) -> Bool {
		return isNextFrom(strIndex, char: char)
	}

	func isNextFrom(index: Int, char: String) -> Bool {
		if index + char.count <= string.count {
			return string[index ..< index + char.count] == char
		}
		return false
	}

	func spaceWith(word: String) -> Int {
		trimWithIndent()
		if let char = retString.lastChar() {
			if !char.isSpace() {
				retString += " "
			}
		}
		append(word)
		retString += " "
		return string.nextNonSpaceIndex(strIndex)
	}

	func spaceWithArray(list: [String]) -> Int? {
		for word in list {
			if isNext(word) {
				return spaceWith(word)
			}
		}
		return nil
	}

	func trimWithIndent() {
		retString = retString.trim()
		if retString.lastChar() == "\n" {
			addIndent()
		}
	}

	func addIndent() {
		for _ in 0 ..< indent + tempIndent {
			retString += "\t"
		}
	}

	func append(string: String) -> Int {
		retString += string
		strIndex += string.count
		return strIndex
	}

	func addToNext(start: Int, stopChar: String) -> Int {
		var index = start
		while index < string.count {
			if isNextFrom(index, char: stopChar) {
				break
			}
			index += 1
		}
		retString += string[start ..< index].trim()
		return index
	}
}