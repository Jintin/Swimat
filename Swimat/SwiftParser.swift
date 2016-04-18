import Foundation

class SwiftParser {
	private static let OPERATOR_LIST: [Character: [String]] = [
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
	var retString = ""
	var strIndex: String.Index
	var indentStack = [Int]()
	var indent = 0
	var tempIndent = 0
	var range: Range<String.Index>
	var checkCursor: (() -> Void)?
	var inSwitch = false
	var switchCount = 0

	init(string: String, range: NSRange? = nil) {
		self.string = string
		self.strIndex = string.startIndex
		self.INDENT_CHAR = "\t"

		if range != nil {
			self.range = string.rangeFromNSRange(range)!
			self.checkCursor = checkCursorStart
		} else {
			self.range = string.startIndex ..< string.startIndex
		}
	}

	func format() -> (string: String, range: NSRange?) {
		#if DEBUG
			let methodStart = NSDate()
		#endif
		while strIndex < string.endIndex {
			let char = string[strIndex]
			strIndex = checkChar(char)
			checkCursor?()
		}
		#if DEBUG
			let executionTime = NSDate().timeIntervalSinceDate(methodStart)
			print("format  executionTime = \(executionTime)");
		#endif
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

		let modify = diff > 0
		if modify {
			target = target.predecessor()
		}
		while diff > 0 {
			diff -= 1
			if retString[target].isSpace() {
				target = retString.lastNonSpaceIndex(target)
			}
			if target > strIndex {
				target = target.predecessor()
			}
		}
		if modify {
			target = target.successor()
		}

		return target
	}

	func checkCursorStart() {
		if strIndex >= range.startIndex {
			checkCursor = checkCursorEnd
			let cursor = range.startIndex
			if cursor == string.startIndex {
				return
			} else if cursor == string.endIndex {
				checkCursor = nil
				range = retString.endIndex ..< retString.endIndex
				return
			}

			let target = getPosition(cursor, now: retString.endIndex)
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
				range.endIndex = getPosition(cursor, now: retString.endIndex)
			}
		}
	}

	func checkChar(char: Character) -> String.Index {
		switch char {
		case "+", "*", "%", "^", "&", ">", "|", "=":
			return spaceWithArray(SwiftParser.OPERATOR_LIST[char]!)!
		case "-":
			if let index = spaceWithArray(SwiftParser.OPERATOR_LIST[char]!) {
				return index
			} else {
				var negative = false
				if retString.count > 0 {
					let last = retString.lastNonSpaceChar(retString.endIndex.predecessor())
					if last.isAZ() {
						let keys = ["case", "return", "if", "for", "while"]
						if keys.contains(retString.lastWord()) {
							negative = true
						}
					} else {
						let keys: [Character] = ["+", "-", "*", "/", "&", "|", "^", "<", ">", ":", "(", "{", "?", "!", "=", ","]
						if keys.contains(last) {
							negative = true
						}
					}
				}
				if negative {
					return append("-")
				}
				return spaceWith("-")
			}
		case "~":
			if let index = spaceWithArray(SwiftParser.OPERATOR_LIST[char]!) {
				return index
			}
			return append(char)
		case "/":
			if isNextChar("/") {
				return addToNext(strIndex, stopChar: "\n")
			} else if isNextChar("*") {
				return addToNext(strIndex, stopWord: "*/")
			}
			return spaceWithArray(SwiftParser.OPERATOR_LIST[char]!)!
		case "<":
			if isNextChar("#") {
				return append("<#")
			}
			if let result = findGeneric(strIndex) {
				retString += result.string
				return result.index
			}
			return spaceWithArray(SwiftParser.OPERATOR_LIST[char]!)!
		case "?":
			if isNextChar("?") {
				return spaceWith("??")
			} else if let tenary = findTenary(strIndex) {
				retString += tenary.string
				return tenary.index
			} else {
				return append(char)
			}
		case ":":
			trimWithIndent()
			retString += ": "
			return string.nextNonSpaceIndex(strIndex.successor())
		case "!":
			if let index = spaceWithArray(SwiftParser.OPERATOR_LIST[char]!) {
				return index
			}
			return append(char)
		case ".":
			if let index = spaceWithArray(SwiftParser.OPERATOR_LIST[char]!) {
				return index
			}
			append(char)
			return string.nextNonSpaceIndex(strIndex)
		case "#":
			if isNextString("#if") {
				indent += 1
				return append("#if")
			} else if isNextString("#else") {
				indent -= 1
				trimWithIndent()
				append("#else")
				indent += 1
				return strIndex
			} else if isNextString("#endif") {
				indent -= 1
				trimWithIndent()
				return append("#endif")
			} else if isNextChar(">") {
				return append("#>")
			} else if isNextChar("!") {
				return addToNext(strIndex, stopChar: "\n")
			}
			break
		case "\"":
			let quote = findQuote(strIndex)
			retString += quote.string
			return quote.index
		case "\n":
			retString = retString.trim()
			checkLineEnd()
			append(char)
			addIndent()
			return string.nextNonSpaceIndex(strIndex)
		case " ", "\t":
			keepSpace()
			return strIndex.successor()
		case ",":
			retString += ", "
			return string.nextNonSpaceIndex(strIndex.successor())
		case "{", "}", "[", "]", "(", ")":
			if char.isUpperBlock() {
				indentStack.append(indent)
				indent += tempIndent + 1
				if inSwitch {
					switchCount += 1
				}
			} else if char.isLowerBlock() {
				indent = indentStack.popLast() ?? 0
				if inSwitch {
					switchCount -= 1
					if switchCount == 0 {
						inSwitch = false
					}
				}
				trimWithIndent()
			}
			break
		default:
			break
		}
		return checkDefault(char)
	}

	func checkDefault(char: Character) -> String.Index {
		append(char)
		while strIndex < string.endIndex {
			let next = string[strIndex]
			if next.isAZ() {
				append(next)
			} else {
				break
			}
		}
		return strIndex
	}

	func checkLineEnd() {
		tempIndent = 0
		if let last = retString.lastChar {
			switch last {
			case ":":
				if !inSwitch {
					tempIndent += 1
				}
				break
			default:
				break
			}
		}
	}
}

extension SwiftParser {
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
			} else if next == "(" {
				let block = findBlock(index)
				index = block.index
				result += block.string
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

	func findTenary(index: String.Index) -> (string: String, index: String.Index)? {
		let start = string.nextNonSpaceIndex(index.successor())
		guard let firstObj = findObject(start) else {
			return nil
		}
		let middle = string.nextNonSpaceIndex(firstObj.index)
		guard string[middle] == ":" else {
			return nil
		}
		let end = string.nextNonSpaceIndex(middle.successor())
		guard let secondObj = findObject(end) else {
			return nil
		}
		return ("? \(firstObj.string) : \(secondObj.string)", secondObj.index)
	}

	func findObject(start: String.Index) -> (string: String, index: String.Index)? {
		var index = start
		var result = ""
		while index < string.endIndex {
			let next = string[index]
			let list: [Character] = ["?", "!", "."]
			if next.isAZ() || next.isOneOf(list) { // TODO check complex case
				result.append(next)
			} else if next == "(" {
				let block = findBlock(index)
				index = block.index
				result += block.string
				continue
			} else {
				if result.isEmpty {
					return nil
				}
				return (result, index)
			}
			index = index.successor()
		}
		return nil
	}

	func findGeneric(start: String.Index) -> (string: String, index: String.Index)? {
		var index = start.successor()
		var count = 1
		var result = "<"
		while index < string.endIndex {
			let next = string[index]

			switch next {
			case "A" ... "z", "0" ... "9", ",", " ", "[", "]", ".", "?", ":":
				result.append(next)
			case "<":
				count += 1
				result.append(next)
			case ">":
				count -= 1
				result.append(next)
				if count == 0 {
					// print("generic:\(result)")
					return (result, index.successor())
				} else if count < 0 {
					return nil
				}
			case "(":
				let block = findBlock(index)
				index = block.index
				result += block.string
				continue
			default:
				return nil
			}

			index = index.successor()
		}
		return nil
	}
}