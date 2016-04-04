import Foundation

class SwiftParser: Parser {

	var range: Range<String.Index>?
	var checkCursor: (() -> Void)?

	func format(string: String, range: NSRange?) -> (string: String, range: NSRange?) {
		let methodStart = NSDate()
		self.string = string
		self.retString = ""
		self.strIndex = string.startIndex
		self.indent = 0
		self.tempIndent = 0
		if range != nil {
			self.checkCursor = checkCursorStart
		}
		self.range = string.rangeFromNSRange(range)

		let checkers = [
			checkBlock,
			checkNewLine,
			checkComment,
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
		if strIndex >= range?.startIndex {
			var target = retString.endIndex.predecessor()
			let cursor = range!.startIndex
			if cursor == string.startIndex {
				checkCursor = checkCursorEnd
				return
			} else if cursor == string.endIndex{
				checkCursor = checkCursorEnd
				range?.startIndex = retString.endIndex
				range?.endIndex = retString.endIndex
				return
			}
			target = getPosition(cursor, now: target)

			if range?.startIndex == range?.endIndex {
				range?.endIndex = target
				checkCursor = nil
			} else {
				checkCursor = checkCursorEnd
			}
			range?.startIndex = target
		}
	}

	func checkCursorEnd() {
		if strIndex >= range?.endIndex {
			let target = retString.endIndex.predecessor()
			let cursor = range!.endIndex
			if cursor == string.startIndex {
				checkCursor = nil
				return
			} else if cursor == string.endIndex{
				checkCursor = nil
				range?.endIndex = retString.endIndex
				return
			}
			range?.endIndex = getPosition(cursor, now: target)
			checkCursor = nil
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
		let obj = SwiftParser().format(result, range: nil) // TODO no need to new obj

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

	func checkOperator(char: Character) -> String.Index? {

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

	func checkComment(char: Character) -> String.Index? {
		if char == "/" {
			if isNextString("//") {
				return addToNext(strIndex, stopChar: "\n")
			} else if isNextString("/*") {
				return addToNext(strIndex, stopChar: "*/")
			}
		}
		return nil
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