import Foundation

class SwiftParser: Parser {

	func format(string: String, range: NSRange) {
		self.string = string
		retString = ""
		strIndex = 0
		let checkers = [checkString, checkComment]

		while strIndex < string.count {
			let char = string[strIndex]
			var find = false
			for checker in checkers {
				if let checkIndex = checker(char) {
					find = true
					strIndex = checkIndex

					break
				}
			}
			if !find {
				append(char)
			}
		}
		print("return:\n" + retString)
	}

	func checkString(char: String) -> Int? {
		if char == "\"" {
			var escape = false
			var index = strIndex + 1
			while index < string.count {
				let next = string[index]
				index += 1
				if !escape && next == "\"" {
					break
				}

				if next == "\\" {
					escape = !escape
				} else {
					escape = false
				}
			}

			print("string:\"" + string[strIndex ..< index] + "\"")
			retString += string[strIndex ..< index]
			return index
		}
		return nil
	}

	func checkComment(char: String) -> Int? {
		if char == "/" {
			if isNext("/") {
				retString += "// "
				let startIndex = nextNonSpaceIndex(strIndex + 2)
				var index = startIndex
				while index < string.count {
					let next = string[index]
					if next == "\n" {
						break
					}
					index += 1
				}
				print("line:\"" + string[startIndex ..< index] + "\"")
				retString += string[startIndex ..< index]
				return index
			} else if isNext("*") {
				print("")
				return 1
			}
		}
		return nil
	}
}