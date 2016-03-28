import Foundation

class SwiftParser: Parser {

	func format(string: String, range: NSRange?) -> String {
		self.string = string
		self.retString = ""
		self.strIndex = 0
		self.indent = 0
		self.tempIndent = 0

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
			} else {
				result += next
			}
			if next == ")" {
				break
			} else {
				index += 1
			}
		}
		let subString = SwiftParser().format(result, range: nil)

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
		return (result, index)
	}

	func checkOperator(char: String) -> Int? {

		switch char {
		case "+":
			let list = ["+++=", "+++", "+=<", "+=", "+"]
			return spaceWithArray(list)
		case "-":
			let list = ["->", "-="]
			if let index = spaceWithArray(list) {
				return index
			} else {
				// TODO check minus or negative
				return spaceWith("-")
			}
		case "~":
			let list = ["~=", "~~>"]
			return spaceWithArray(list)
		case "*", "/", "%", "^":
			let list = ["\(char)=", char]
			return spaceWithArray(list)
		case "&":
			let list = ["&+", "&-", "&*", "&/", "&%", "&&=", "&&", "&="]
			return spaceWithArray(list)
		case "<":
			// TODO check generic
			return nil
		case ">", "|":
			let list = [
				"\(char)\(char)\(char)",
				"\(char)\(char)=",
				"\(char)\(char)",
				"\(char)=",
				char]
			return spaceWithArray(list)
		case "!":
			let list = ["!==", "!="]
			return spaceWithArray(list)
		case "=":
			let list = ["===", "==", "="]
			return spaceWithArray(list)
		case "?":
			// TODO check ? ?? a?b:c
			return nil
		case ":":
			// TODO check a?b:c
			return nil
		case ".":
			// TODO check
			return nil
		case "#":
			// TODO check
			return nil
		default:
			return nil
		}
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
		if char == "{" {
			print("upper")
			indent += 1
		} else if char == "}" {
			print("lower")
			if indent != 0 {
				indent -= 1
			}
			trimWithIndent()
		}
		return nil
	}
}