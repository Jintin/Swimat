import Foundation

class SwiftParser: Parser {

	func format(string: String, range: NSRange?) -> String {
		self.string = string
		self.retString = ""
		self.strIndex = 0
		self.indent = 0

		let checkers = [checkString, checkComment, checkBlock, checkNewLine, checkOperator]

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
		return retString
	}

	func findBlock(start: Int) -> (string: String, index: Int) {
		var index = start
		var result = ""
		while index < string.count {
			let next = string[index]

			if next == "\"" {
				let quote = findQuote(index)

				index = quote.index
				result += quote.string
			} else if next == ")" {
				result += next
				break
			} else {
				result += next
			}
			index += 1
		}
		let subString = SwiftParser().format(result, range: nil)
		print("block\(start):\(index):" + subString)

		return (subString, index)
	}

	func findQuote(start: Int) -> (string: String, index: Int) {
		var escape = false
		var index = start + 1
		var result = "\""
		while index < string.count {
			let next = string[index]

			if escape && next == "(" {
				let block = findBlock(index)
				index = block.index
				result += block.string
			} else {
				result += next
			}

			if !escape && next == "\"" {
				break
			}
			if next == "\\" {
				escape = !escape
			} else {
				escape = false
			}
			index += 1
		}
		print("quote\(start):\(index):" + result)
		return (result, index)
	}

//	"a+b=c\(d+e"\(f+g)"+h)"

	func checkOperator(char: String) -> Int? {
		if char == "+" {
			return spaceWith("+")
		}
		return nil
	}

	func checkString(char: String) -> Int? {
		if char == "\"" {
			let quote = findQuote(strIndex)

			print("string:" + quote.string)
			retString += quote.string

			return quote.index + 1
		}
		return nil
	}

	func checkComment(char: String) -> Int? {
		if char == "/" {
			if isNext("//") {
				print("line")
				retString += "// "
				let startIndex = string.nextNonSpaceIndex(strIndex + 2)

				return addToNext(startIndex, stopChar: "\n")
			} else if isNext("/*") {
				print("block")
				return addToNext(strIndex, stopChar: "*/")
			}
		}
		return nil
	}

	func checkNewLine(char: String) -> Int? {
		if char == "\n" {
			print("new line")
			retString += "\n"
			addIndent()
//			isNext(<#T##char: String##String#>)
			return string.nextNonSpaceIndex(strIndex + 1)
		}
		return nil
	}

	func checkBlock(char: String) -> Int? {
		if char.isUpperBlock() {
			print("upper")
			indent += 1
		} else if char.isLowerBlock() {
			print("lower")

			if indent != 0 {
				indent -= 1
			}
			trimWithIndent()
		}
		return nil
	}
}