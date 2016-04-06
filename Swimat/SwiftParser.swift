import Foundation

class SwiftParser {

	let OPERATOR_LIST: [Character: [String]] = [
		"+": ["+=<", "+=", "+++=", "+++", "+"],
		"-": ["->", "-=", "-<<"],
		"*": ["*=", "*"],
		"/": ["/=", "/"],
		"~": ["~=", "~~>"],
		"%": ["%=", "%"],
		"^": ["^=", "^"],
		"&": ["&&=", "&&", "&=", "&+", "&-", "&*", "&/", "&%"],
		"<": ["<<<", "<<=", "<<", "<=", "<~~", "<~", "<--", "<-<", "<-", "<^>", "<|>", "<*>", "<||?", "<||", "<|?", "<|", "<"],
		">": [">>>", ">>=", ">>-", ">>", ">=", ">->", ">"],
		"|": ["|||", "||=", "||", "|=", "|"],
		"!": ["!==", "!="],
		"=": ["===", "==", "="],
		".": ["...", "..<"]
	]
	let INDENT_CHAR: Character
	let string: String
	var retString: String
	var strIndex: String.Index
	var indent: Int
	var tempIndent: Int
	var range: Range<String.Index>
	var checkCursor: (() -> Void)?

	init(string: String, range: NSRange? = nil) {
		self.string = string
		self.retString = ""
		self.strIndex = string.startIndex
		self.indent = 0
		self.tempIndent = 0
		self.INDENT_CHAR = "\t"

		if range != nil {
			self.range = string.rangeFromNSRange(range)!
			self.checkCursor = checkCursorStart
		} else {
			self.range = string.startIndex ..< string.startIndex
		}
	}

	func format() -> (string: String, range: NSRange?) {
		let methodStart = NSDate()

		let checkers = [
			checkBlock,
			checkNewLine,
			checkOperator,
			checkString,
			checkDefault
		]
		while strIndex < string.endIndex {

			let char = string[strIndex]
			for checker in checkers {
				if let checkIndex = checker(char) {
					strIndex = checkIndex
					break
				}
			}
			checkCursor?()
		}
		let executionTime = NSDate().timeIntervalSinceDate(methodStart)
		print("format  executionTime = \(executionTime)");

		return (retString, retString.nsRangeFromRange(self.range))
	}

	func getPosition(start: String.Index, now: String.Index) -> String.Index {
		var cursor = start
		var target = now
		var diff = 0

		while strIndex > cursor {
			// TODO: if space is in quote it should be count
			if !string[cursor].isSpace() {
				diff += 1
			}
			cursor = cursor.successor()
		}

		while diff > 0 {
			diff -= 1
			if retString[target].isSpace() {
				target = retString.lastNonSpaceIndex(target)
			}
			target = target.predecessor()
		}

		return target.successor()
	}

	func checkCursorStart() {
		if strIndex >= range.startIndex {
			checkCursor = checkCursorEnd
			let cursor = range.startIndex
			if cursor == string.startIndex {
				return
			} else if cursor == string.endIndex {
				checkCursor = nil
				range.startIndex = retString.endIndex
				range.endIndex = retString.endIndex
				return
			}

			let target = getPosition(cursor, now: retString.endIndex.predecessor())
			if range.startIndex == range.endIndex {
				checkCursor = nil
				range.endIndex = target
			}
			range.startIndex = target
		}
	}

	func checkCursorEnd() {
		if strIndex >= range.endIndex {
			checkCursor = nil
			let cursor = range.endIndex
			if cursor == string.endIndex {
				range.endIndex = retString.endIndex
			} else {
				let target = retString.endIndex.predecessor()
				range.endIndex = getPosition(cursor, now: target)
			}
		}
	}

	func findBlock(start: String.Index) -> (string: String, index: String.Index) {
		var index = start.successor()
		var result = "("
		while index < string.endIndex {
			let next = string[index]

			if next == "\"" {
				let quote = findQuote(index)
				index = quote.index
				result += quote.string
				continue
			} else {
				result.append(next)
			}
			index = index.successor()
			if next == ")" {
				break
			}
		}
		let obj = SwiftParser(string: result).format() // TODO: no need to new obj

		return (obj.string, index)
	}

	func findQuote(start: String.Index) -> (string: String, index: String.Index) {
		var escape = false
		var index = start.successor()
		var result = "\""
		while index < string.endIndex {
			let next = string[index]

			if escape && next == "(" {
				let block = findBlock(index)
				index = block.index
				result += block.string
				escape = false
				continue
			} else {
				result.append(next)
			}

			index = index.successor()
			if !escape && next == "\"" {
				return (result, index)
			}
			if next == "\\" {
				escape = !escape
			} else {
				escape = false
			}
		}
		return (result, string.endIndex.predecessor())
	}

	func checkString(char: Character) -> String.Index? {
		if char == "\"" {
			let quote = findQuote(strIndex)
			retString += quote.string
			return quote.index
		}
		return nil
	}

	func findGeneric(start: String.Index) -> (string: String, index: String.Index)? {
		var index = start.successor()
		var count = 1
		var result = "<"
		while index < string.endIndex {
			let next = string[index]
			if next == "<" {
				count += 1
			} else if next == ">" {
				count -= 1
				if count == 0 {
					return (result, index)
				}
			}
			result.append(next)
			index = index.successor()
		}
		return nil
	}

	func checkOperator(char: Character) -> String.Index? {

		switch char {
		case "+", "*", "%", "^", "&", ">", "|", "!", "=":
			return spaceWithArray(OPERATOR_LIST[char]!)
		case "-":
			if let index = spaceWithArray(OPERATOR_LIST[char]!) {
				return index
			} else {
				// TODO: check minus or negative
				return spaceWith("-")
			}
		case "~":
			if let index = spaceWithArray(OPERATOR_LIST[char]!) {
				return index
			}
			return append("~")
		case "/":
			if isNextString("//") {
				return addToNext(strIndex, stopChar: "\n")
			} else if isNextString("/*") {
				return addToNext(strIndex, stopChar: "*/")
			}
			return spaceWithArray(OPERATOR_LIST[char]!)
		case "<":
			// TODO: check generic
			return spaceWithArray(OPERATOR_LIST[char]!)
		case "?":
			if isNextString("??") {
				return spaceWith("??")
			}
			// TODO: check ? ?? a?b:c
			return nil
		case ":":
			// TODO: check a?b:c
			append(": ")
			return string.nextNonSpaceIndex(strIndex)
		case ".":
			if let index = spaceWithArray(OPERATOR_LIST[char]!) {
				return index
			} else {
				trimWithIndent()
				append(".")
				return string.nextNonSpaceIndex(strIndex)
			}
		case "#":
			// TODO: check
			return nil
		default:
			return nil
		}
	}

	func checkNewLine(char: Character) -> String.Index? {
		if char == "\n" {
			retString += "\n"
			addIndent()
			return string.nextNonSpaceIndex(strIndex.successor())
		}
		return nil
	}

	func checkBlock(char: Character) -> String.Index? {
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

	func checkDefault(char: Character) -> String.Index? {
		retString.append(char)
		return strIndex.successor()
	}
}