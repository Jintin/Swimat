import Foundation

class SwiftParser: Parser {

	func format(string: String, range: NSRange?) -> (string: String, range: NSRange?) {
		let methodStart = NSDate()
		self.string = string
		self.retString = ""
		self.strIndex = 0
		self.indent = 0
		self.tempIndent = 0

		let checkers = [
			checkString,
			checkComment,
			checkBlock,
			checkNewLine,
			checkOperator
		]

		for (index, char) in string.characters.enumerate() {
			if index != strIndex {
				continue
			}
			var find = false
			for checker in checkers {
				if let checkIndex = checker(char) {
					find = true
					strIndex = checkIndex
					break
				}
			}
			if !find {
				retString.append(char)
				strIndex += 1
			}
		}
		print("return:\n" + retString)
		let executionTime = NSDate().timeIntervalSinceDate(methodStart)
		print("format executionTime = \(executionTime)");
		return (retString, range)
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
				result.append(next)
			}
			if next == ")" {
				break
			} else {
				index += 1
			}
		}
		let obj = SwiftParser().format(result, range: nil) // TODO no need to new obj

		return (obj.string, index)
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
				result.append(next)
			}

			if !escape && next == "\"" {
				break
			} else {
				index += 1
			}
			if next == "\\" {
				escape = !escape
			} else {
				escape = false
			}
		}
		return (result, index)
	}

	func checkString(char: Character) -> Int? {
		if char == "\"" {
			let quote = findQuote(strIndex)
			retString += quote.string
			return quote.index + 1
		}
		return nil
	}

	func checkOperator(char: Character) -> Int? {

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
			if let index = spaceWithArray(list) {
				return index
			} else {
				return append("~")
			}
		case "*", "/", "%", "^":
			let a = String(char)
			let list = ["\(a)=", a]
			return spaceWithArray(list)
		case "&":
			let list = ["&+", "&-", "&*", "&/", "&%", "&&=", "&&", "&="]
			return spaceWithArray(list)
		case "<":
			// TODO check generic
			return nil
		case ">", "|":
			let a = String(char)
			let list = [
				"\(a)\(a)\(a)",
				"\(a)\(a)=",
				"\(a)\(a)",
				"\(a)=",
				a]
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
			let list = ["...", "..<"]
			if let index = spaceWithArray(list) {
				return index
			} else {
				trimWithIndent()
				append(".")
				return string.nextNonSpaceIndex(strIndex)
			}
		case "#":
			// TODO check
			return nil
		default:
			return nil
		}
	}

	func checkComment(char: Character) -> Int? {
		if char == "/" {
			if isNext("//") {
				retString += "// "
				let startIndex = string.nextNonSpaceIndex(strIndex + 2)

				return addToNext(startIndex, stopChar: "\n")
			} else if isNext("/*") {
				return addToNext(strIndex, stopChar: "*/")
			}
		}
		return nil
	}

	func checkNewLine(char: Character) -> Int? {
		if char == "\n" {
			retString += "\n"
			addIndent()
//			isNext(<#T##char: String##String#>)
			return string.nextNonSpaceIndex(strIndex + 1)
		}
		return nil
	}

	func checkBlock(char: Character) -> Int? {
		if char == "{" {
			indent += 1
		} else if char == "}" {
			if indent != 0 {
				indent -= 1
			}
			trimWithIndent()
		}
		return nil
	}
}