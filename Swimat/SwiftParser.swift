import Foundation


class SwiftParser {

	private static let OperatorList: [Character: [String]] = [
		"+": ["+=<", "+=", "+++=", "+++", "+"],
		"-": ["->", "-=", "-<<"],
		"*": ["*=", "*"],
		"/": ["/=", "/"],
		"~": ["~=", "~~>"],
		"%": ["%=", "%"],
		"^": ["^="],
		"&": ["&&=", "&&", "&=", "&+", "&-", "&*", "&/", "&%"],
		"<": ["<<<", "<<=", "<<", "<=", "<~~", "<~", "<--", "<-<", "<-", "<^>", "<|>", "<*>", "<||?", "<||", "<|?", "<|", "<"],
		">": [">>>", ">>=", ">>-", ">>", ">=", ">->", ">"],
		"|": ["|||", "||=", "||", "|=", "|"],
		"!": ["!==", "!="],
		"=": ["===", "==", "="],
		".": ["...", "..<"]
	]

	private static let NegativeCheckSigns: [Character] = ["+", "-", "*", "/", "&", "|", "^", "<", ">", ":", "(", "{", "?", "!", "=", ",", "."]
	private static let NegativeCheckKeys = ["case", "return", "if", "for", "while", "in"]

	let indentChar: String
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
		strIndex = string.startIndex
		indentChar = Prefs.getIndent()

		if range != nil {
			self.range = string.rangeFromNSRange(range)!
			checkCursor = checkCursorStart
		} else {
			self.range = string.startIndex ..< string.startIndex
		}
	}

	func format() -> (string: String, range: NSRange?) {
		while strIndex < string.endIndex {
			let char = string[strIndex]
			strIndex = checkChar(char)
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
		case "+", "*", "%", ">", "|", "=":
			return spaceWithArray(SwiftParser.OperatorList[char]!)!
		case "-":
			if let index = spaceWithArray(SwiftParser.OperatorList[char]!) {
				return index
			} else {
				var negative = false
				if retString.count > 0 {
					let last = retString.lastNonSpaceChar(retString.endIndex.predecessor())
					if last.isAZ() {
						if SwiftParser.NegativeCheckKeys.contains(retString.lastWord()) {
							negative = true
						}
					} else {
						if SwiftParser.NegativeCheckSigns.contains(last) {
							negative = true
						}
					}
				}
				if negative {
					return addChar(char)
				}
				return spaceWith("-")
			}
		case "~", "^", ".", "!", "&":
			//TODO: check next if operator first
			if let index = spaceWithArray(SwiftParser.OperatorList[char]!) {
				return index
			}
			return addChar(char)
		case "/":
			if isNextChar("/") {
				strIndex = addToNext(strIndex, stopChar: "\n")
				addIndent()
				return strIndex
			} else if isNextChar("*") {
				return addToNext(strIndex, stopWord: "*/")
			}
			return spaceWithArray(SwiftParser.OperatorList[char]!)!
		case "<":
			if isNextChar("#") {
				return addString("<#")
			}
			if let result = string.findGeneric(strIndex) {
				retString += result.string
				return result.index
			}
			return spaceWithArray(SwiftParser.OperatorList[char]!)!
		case "?":
			if isNextChar("?") {
				// TODO: check double optional or nil check
				return addString("??")
			} else if let tenary = string.findTenary(strIndex) {
				keepSpace()
				retString += tenary.string
				return tenary.index
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
				strIndex = addToNext(strIndex, stopChar: "\n")
				addIndent()
				return strIndex
			}
			break
		case "\"":
			let quote = string.findQuote(strIndex)
			retString += quote.string
			return quote.index
		case "\n":
			retString = retString.trim()
			checkLineEnd()
			strIndex = addChar(char)
			addIndent()
			return string.nextNonSpaceIndex(strIndex)
		case " ", "\t":
			keepSpace()
			return strIndex.successor()
		case ",":
			trimWithIndent()
			retString += ", "
			return string.nextNonSpaceIndex(strIndex.successor())
		case "{", "[", "(":
			indentStack.append(indent + tempIndent)
			indent += tempIndent + 1
			if inSwitch {
				switchCount += 1
			}
			if char == "{" {
				if let last = retString.lastChar where !last.isLowerBlock() {
					keepSpace()
				}

				retString += "{ "
				return strIndex.successor()
			} else {
				return addChar(char)
			}
		case "}", "]", ")":
			indent = indentStack.popLast() ?? 0
			if inSwitch {
				switchCount -= 1
				if switchCount == 0 {
					inSwitch = false
				}
			}

			trimWithIndent() // TODO: change to newline check
			if char == "}" {

				keepSpace() // TODO: if last is not lower bracelet
				retString += "} "
				return string.nextNonSpaceIndex(strIndex.successor())
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
		tempIndent = 0
		if let last = retString.lastChar {
			switch last {
			case ":":
				if !inSwitch {
					tempIndent += 1
				}
				break
			case ",":
				// TODO: if is not in [] or ()
				break
			default:
				break
			}
		}
		// TODO: check next if ? :

	}

}
