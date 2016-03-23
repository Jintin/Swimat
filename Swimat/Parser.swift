import Foundation

class Parser {
	var string = ""
	var retString = ""
	var strIndex = 0
	var indent = 0

	func isNext(char: String) -> Bool {
		if strIndex + char.count <= string.count {
			return string[strIndex ..< strIndex + char.count] == char
		}
		return false
	}

	func append(string: String) {
		retString += string
		strIndex += string.count
	}
}