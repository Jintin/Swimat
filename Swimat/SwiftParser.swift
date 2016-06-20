import Foundation

class SwiftParser {

	enum FormatError: ErrorType {
		case StringError
	}

	private static let OperatorList: [Character: [String]] = [
		"+": ["+=<", "+=", "+++=", "+++", "+"],
		"-": ["->", "-=", "-<<"],
		"*": ["*=", "*"],
		"/": ["/=", "/"],
		"~": ["~=", "~~>"],
		"%": ["%=", "%"],
		"^": ["^="],
		"&": ["&&=", "&&&", "&&", "&=", "&+", "&-", "&*", "&/", "&%"],
		"<": ["<<<", "<<=", "<<", "<=", "<~~", "<~", "<--", "<-<", "<-", "<^>", "<|>", "<*>", "<||?", "<||", "<|?", "<|", "<"],
		">": [">>>", ">>=", ">>-", ">>", ">=", ">->", ">"],
		"|": ["|||", "||=", "||", "|=", "|"],
		"!": ["!==", "!="],
		"=": ["===", "==", "="]
	]

	private static let NegativeCheckSigns: [Character] = ["+", "-", "*", "/", "&", "|", "^", "<", ">", ":", "(", "[", "{", "=", ",", "."]
	private static let NegativeCheckKeys = ["case", "return", "if", "for", "while", "in"]
	private static let Numbers: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

	let indentChar: String
	let string: String
	var retString = ""
	var strIndex: String.Index
	var blockStack = [Block]()
	var blockType: BlockType = .Curly
	var indent = 0
	var tempIndent = 0
	var range: Range<String.Index>
	var checkCursor: (() -> Void)?
	var inSwitch = false
	var switchCount = 0
	var newlineIndex: String.Index

	enum BlockType: Character {
		case Parentheses = "(", Square = "[", Curly = "{"

		static func from(char: Character) -> BlockType {
			switch char {
			case "(":
				return .Parentheses
			case "[":
				return .Square
			case "{":
				return .Curly
			default:
				return .Curly
			}
		}

	}

	struct Block {
		let indent: Int
		let tempIndent: Int
		let position: Int
		let type: BlockType
	}

	init(string: String, range: NSRange? = nil) {
		self.string = string
		strIndex = string.startIndex
		newlineIndex = string.startIndex
		indentChar = Prefs.getIndent()

		if range != nil {
			self.range = string.rangeFromNSRange(range)!
			checkCursor = checkCursorStart
		} else {
			self.range = string.startIndex ..< string.startIndex
		}
	}

	func format() throws -> (string: String, range: NSRange?) {
		while strIndex < string.endIndex {
			let char = string[strIndex]
			strIndex = try checkChar(char)
			checkCursor?()
		}
		retString = retString.trim()
		if range.startIndex > retString.endIndex {
			range.startIndex = retString.endIndex
		}
		if range.endIndex > retString.endIndex {
			range.endIndex = retString.endIndex
		}
		return (retString, retString.nsRangeFromRange(range))
	}

	func getPosition(start: String.Index) -> String.Index {
		var cursor = start // range position
		var diff = 0

		while strIndex > cursor {
			// TODO: if space is in quote it should be count

			if !string[cursor].isSpace() {
				diff += 1
			}
			cursor = cursor.successor()
		}
		if retString.endIndex != retString.startIndex {
			var target = retString.endIndex.predecessor()
			while diff > 0 {
				diff -= 1
				if retString[target].isSpace() {
					target = retString.lastNonSpaceIndex(target)
				}
				target = target.predecessor()
			}
			return target.successor()
		}

		return retString.endIndex
	}

	func checkCursorStart() {
		if strIndex >= range.startIndex {
			let cursor = range.startIndex
			if cursor == range.endIndex {
				checkCursor = nil
			} else {
				checkCursor = checkCursorEnd
			}
			if cursor == string.startIndex {

				return
			} else if cursor == string.endIndex {
				checkCursor = nil
				range = retString.endIndex ..< retString.endIndex
				return
			}

			let target = getPosition(cursor)
			if range.startIndex == range.endIndex {
				checkCursor = nil
				range.endIndex = target
				range.startIndex = target
			} else {
				var temp = string.substringToIndex((cursor))
				// TODO: cannot decrement startIndex
				if target == retString.startIndex {
					temp += retString.substringFromIndex(target)
				} else {
					temp += retString.substringFromIndex(retString.lastNonSpaceIndex(target.predecessor()).successor())
				}
				retString = temp
			}
		}
	}

	func checkCursorEnd() {
		if strIndex >= range.endIndex {
			checkCursor = nil
			let cursor = range.endIndex
			if cursor == string.endIndex {
				range.endIndex = retString.endIndex
			} else {
				range.endIndex = getPosition(cursor)
				retString = retString.substringToIndex(retString.nextNonSpaceIndex(range.endIndex)) + string.substringFromIndex(cursor)
				strIndex = string.endIndex
			}
		}
	}

	func checkChar(char: Character) throws -> String.Index {
		switch char {
		case "+", "*", "%", ">", "|", "=":
			return spaceWithArray(SwiftParser.OperatorList[char]!)!
		case "-":
			if let index = spaceWithArray(SwiftParser.OperatorList[char]!) {
				return index
			} else {
				var noSpace = false
				if retString.count > 0 {
					// check scientific notation
					if strIndex != string.endIndex {
						if string[strIndex.predecessor()] == "e" && SwiftParser.Numbers.contains(string[strIndex.successor()]) {
							noSpace = true
						}
					}
					// check negative
					let last = retString.lastNonSpaceChar(retString.endIndex.predecessor())
					if last.isAZ() {
						if SwiftParser.NegativeCheckKeys.contains(retString.lastWord()) {
							noSpace = true
						}
					} else {
						if SwiftParser.NegativeCheckSigns.contains(last) {
							noSpace = true
						}
					}
				}
				if noSpace {
					return addChar(char)
				}
				return spaceWith("-")
			}
		case "~", "^", "!", "&":
			if let index = spaceWithArray(SwiftParser.OperatorList[char]!) {
				return index
			}
			return addChar(char)
		case ".":
			if isNextChar(".") {
				if isNextString("...") {
					return addString("...")
				} else if isNextString("..<") {
					return addString("..<")
				}
			}
			return addChar(char)
		case "/":
			if isNextChar("/") {
				return addToLineEnd(strIndex)
			} else if isNextChar("*") {
				return addToNext(strIndex, stopWord: "*/")
			}
			return spaceWithArray(SwiftParser.OperatorList[char]!)!
		case "<":
			if isNextChar("#") {
				return addString("<#")
			}
			if let result = try string.findGeneric(strIndex) {
				retString += result.string
				return result.index
			}
			return spaceWithArray(SwiftParser.OperatorList[char]!)!
		case "?":
			if isNextChar("?") {
				// TODO: check double optional or nil check
				return addString("??")
			} else if let ternary = try string.findTernary(strIndex) {
				keepSpace()
				retString += ternary.string
				return ternary.index
			} else {
				return addChar(char)
			}
		case ":":
			trimWithIndent()
			retString += ": "
			return string.nextNonSpaceIndex(strIndex.successor())
		case "#":
			if isNextString("#if") {
				indent += 1
				return addString("#if")
			} else if isNextString("#else") {
				indent -= 1
				trimWithIndent()
				indent += 1
				return addString("#else")
			} else if isNextString("#endif") {
				indent -= 1
				trimWithIndent()
				return addString("#endif")
			} else if isNextChar(">") {
				return addString("#>")
			} else if isNextChar("!") {
				return addToLineEnd(strIndex)
			}
			break
		case "\"":
			let quote = try string.findQuote(strIndex)
			retString += quote.string
			return quote.index
		case "\n":
			newlineIndex = strIndex
			retString = retString.trim()
			checkLineEnd()
			strIndex = addChar(char)
			if !isNextString("//") {
				addIndent()
				if isBetween(("if", "let"), ("guard", "let")) {
					retString += indentChar
				} else if isNextWord("else") {
					retString += indentChar
				}
			}
			return string.nextNonSpaceIndex(strIndex)
		case " ", "\t":
			keepSpace()
			return strIndex.successor()
		case ",":
			trimWithIndent()
			retString += ", "
			return string.nextNonSpaceIndex(strIndex.successor())
		case "{", "[", "(":
			let position = newlineIndex.distanceTo(strIndex) - indent - tempIndent
			let block = Block(indent: indent, tempIndent: tempIndent, position: position, type: blockType)
			blockStack.append(block)
			blockType = BlockType.from(char)
			if blockType == .Parentheses {
				indent += tempIndent
			} else {
				indent += tempIndent + 1
			}
			if inSwitch && char == "{" {
				switchCount += 1
			}
			if char == "{" {
				if let last = retString.lastChar where !last.isUpperBlock() {
					keepSpace()
				}

				retString += "{ "
				return strIndex.successor()
			} else {
				return addChar(char)
			}
		case "}", "]", ")":
			if let block = blockStack.popLast() {
				indent = block.indent
				tempIndent = block.tempIndent
				blockType = block.type
			} else {
				indent = 0
				tempIndent = 0
				blockType = .Curly
			}
			if inSwitch && char == "}" {
				switchCount -= 1
				if switchCount == 0 {
					inSwitch = false
				}
			}

			trimWithIndent() // TODO: change to newline check
			if char == "}" {
				keepSpace()
				let next = strIndex.successor()
				if next < string.endIndex && string[next].isAZ() {
					retString += "} "
				} else {
					retString += "}"
				}
				return next
			} else {
				return addChar(char)
			}
		default:
			return checkDefault(char)
		}
		return checkDefault(char)
	}

	func checkDefault(char: Character) -> String.Index {
		strIndex = addChar(char)
		while strIndex < string.endIndex {
			let next = string[strIndex]
			if next.isAZ() {
				strIndex = addChar(next)
			} else {
				break
			}
		}
		return strIndex
	}

	func checkLineEnd() {

		let check = {
			(char: Character) -> Int? in
			switch char {
			case "+", "-", "*", "=", ".":
				return 1
			case "/": // TODO: check word, nor char
				break
			case ":":
				if !self.inSwitch {
					return 1
				}
			case ",":
				if self.blockType == .Curly {
					return 1
				}
			default:
				break
			}
			return nil
		}

		if let last = retString.lastChar {
			if let result = check(last) {
				tempIndent = result
				return
			}
		}

		if strIndex < string.endIndex {
			let next = string.nextNonSpaceIndex(strIndex.successor())
			if next < string.endIndex {
				if let result = check(string[next]) {
					tempIndent = result
					return
				}
				if string[next] == "?" {
					tempIndent = 1
					return
				}
			}
			tempIndent = 0
			// TODO: check next if ? :

		}
	}

}
