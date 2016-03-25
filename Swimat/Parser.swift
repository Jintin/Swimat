import Foundation

class Parser {
	var string = ""
	var retString = ""
	var strIndex = 0
	var indent = 0

	func isNext(char: String) -> Bool {
		return isNextFrom(strIndex, char: char)
	}

	func isNextFrom(index: Int, char: String) -> Bool {
		if index + char.count <= string.count {
			return string[index ..< index + char.count] == char
		}
		return false
	}

	func trimWithIndent() {
		retString = retString.trim()
		if retString[retString.count - 1] == "\n" {
			addIndent()
		}
	}

	func addIndent() {
		for _ in 0 ..< indent {
			retString += "\t"
		}
	}

	func append(string: String) {
		retString += string
		strIndex += string.count
	}

	func addToNext(start: Int, stopChar: String) -> Int {
		var index = start
		while index < string.count {
			if isNextFrom(index, char: stopChar) {
				break
			}
			index += 1
		}
		print("next:\"" + string[start ..< index] + "\"")
		retString += string[start ..< index].trim()
		return index
	}
}