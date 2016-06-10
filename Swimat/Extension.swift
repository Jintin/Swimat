import Foundation

extension String {

	var count: Int {
		return characters.count
	}

	var lastChar: Character? {
		return characters.last
	}

	func lastWord() -> String {

		if count > 0 {
			let end = lastNonBlankIndex(endIndex.predecessor())
			if end != startIndex || !self[end].isBlank() {
				let start = lastStringIndex(end) { $0.isBlank() }
				if self[start].isBlank() {
					return self[start.successor() ... end]
				}
				return self[start ... end]
			}
		}
		return ""
	}

	func trim() -> String {
		return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	}

	func findDiff(string: String) -> (range1: Range<String.Index>, range2: Range<String.Index>)? {
		#if DEBUG
			let methodStart = NSDate()
		#endif
		if isEmpty || string.isEmpty {
			return nil
		}

		let start = commonPrefixWithString(string, options: .AnchoredSearch).endIndex

		var end1 = endIndex.predecessor()
		var end2 = string.endIndex.predecessor()
		while self[end1] == string[end2] {
			if end1 > start && end2 > start {
				end1 = end1.predecessor()
				end2 = end2.predecessor()
			} else {
				break
			}
		}
		end1 = end1.successor()
		end2 = end2.successor()
		#if DEBUG
			let executionTime = NSDate().timeIntervalSinceDate(methodStart)
			print("\(#function) executionTime = \(executionTime)")
		#endif
		if start == end1 && start == end2 {
			return nil
		}
		return (start ..< end1, start ..< end2)
	}

	func rangeFromNSRange(nsRange: NSRange?) -> Range<String.Index>? {
		if let range = nsRange {
			let from16 = utf16.startIndex.advancedBy(range.location, limit: utf16.endIndex)
			let to16 = from16.advancedBy(range.length, limit: utf16.endIndex)
			if let from = String.Index(from16, within: self),
				to = String.Index(to16, within: self) {
					return from ..< to
				}
		}
		return nil
	}

	func nsRangeFromRange(strRange: Range<String.Index>?) -> NSRange? {
		if let range = strRange {
			let utf16view = utf16

			let from = String.UTF16View.Index(range.startIndex, within: utf16view)
			let to = String.UTF16View.Index(range.endIndex, within: utf16view)

			return NSMakeRange(utf16view.startIndex.distanceTo(from), from.distanceTo(to))
		}
		return nil
	}

	func nextStringIndex(start: String.Index, @noescape checker: Character -> Bool) -> String.Index {
		var index = start
		while index < endIndex {
			if checker(self[index]) {
				break
			}
			index = index.successor()
		}
		return index
	}

	func nextNonSpaceIndex(index: String.Index) -> String.Index {
		return nextStringIndex(index) { !$0.isSpace() }
	}

	func lastStringIndex(start: String.Index, @noescape checker: Character -> Bool) -> String.Index {
		var index = start
		while index > startIndex {
			if checker(self[index]) {
				break
			}
			index = index.predecessor()
		}
		return index
	}

	func lastNonSpaceIndex(start: String.Index) -> String.Index {
		return lastStringIndex(start) { !$0.isSpace() }
	}

	func lastNonSpaceChar(start: String.Index) -> Character {
		return self[lastNonSpaceIndex(start)]
	}

	func lastNonBlankIndex(start: String.Index) -> String.Index {
		return lastStringIndex(start) { !$0.isBlank() }
	}

}

extension String {

	func findParentheses(start: String.Index) throws -> (string: String, index: String.Index) {
		return try findBlock(start, startSign: "(", endSign: ")")
	}

	func findSquare(start: String.Index) throws -> (string: String, index: String.Index) {
		return try findBlock(start, startSign: "[", endSign: "]")
	}

	func findBlock(start: String.Index, startSign: String, endSign: Character) throws -> (string: String, index: String.Index) {
		var index = start.successor()
		var result = startSign
		while index < endIndex {
			let next = self[index]

			if next == "\"" {
				let quote = try findQuote(index)
				index = quote.index
				result += quote.string
				continue
			} else if next == "(" {
				let block = try findParentheses(index)
				index = block.index
				result += block.string
				continue
			} else {
				result.append(next)
			}
			index = index.successor()
			if next == endSign {
				break
			}
		}
		// TODO: no need to new obj
		let obj = try SwiftParser(string: result).format()
		return (obj.string, index)
	}

	func findQuote(start: String.Index) throws -> (string: String, index: String.Index) {
		var escape = false
		var index = start.successor()
		var result = "\""
		while index < endIndex {
			let next = self[index]
			if next == "\n" {
				throw SwiftParser.FormatError.StringError
			}

			if escape && next == "(" {
				let block = try findParentheses(index)
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
		return (result, endIndex.predecessor())
	}

	func findTernary(index: String.Index) throws -> (string: String, index: String.Index)? {
		let start = nextNonSpaceIndex(index.successor())
		guard let first = try findObject(start) else {
			return nil
		}
		let middle = nextNonSpaceIndex(first.index)
		guard self[middle] == ":" else {
			return nil
		}
		let end = nextNonSpaceIndex(middle.successor())
		guard let second = try findObject(end) else {
			return nil
		}
		return ("? \(first.string) : \(second.string)", second.index)
	}

	func findObject(start: String.Index) throws -> (string: String, index: String.Index)? {
		var index = start
		var result = ""
		while index < endIndex {
			let next = self[index]
			let list: [Character] = ["?", "!", "."]
			if next.isAZ() || list.contains(next) { // TODO: check complex case
				result.append(next)
			} else if next == "[" {
				let block = try findSquare(index)
				index = block.index
				result += block.string
				continue
			} else if next == "(" {
				let block = try findParentheses(index)
				index = block.index
				result += block.string
				continue
			} else if next == "\"" {
				let quote = try findQuote(index)
				index = quote.index
				result += quote.string
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

	func findGeneric(start: String.Index) throws -> (string: String, index: String.Index)? {
		var index = start.successor()
		var count = 1
		var result = "<"
		while index < endIndex {
			let next = self[index]

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
					return (result, index.successor())
				} else if count < 0 {
					return nil
				}
			case "\"":
				let quote = try findQuote(index)
				index = quote.index
				result += quote.string
				continue
			case "(":
				let block = try findParentheses(index)
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

extension Character {

	func isAZ() -> Bool {
		switch self {
		case "A" ... "Z", "a" ... "z", "0" ... "9":
			return true
		default:
			return false
		}
	}

	func isUpperBlock() -> Bool {
		return self == "{" || self == "[" || self == "("
	}

	func isLowerBlock() -> Bool {
		return self == "}" || self == "]" || self == ")"
	}

	func isSpace() -> Bool {
		return self == " " || self == "\t"
	}

	func isBlank() -> Bool {
		return isSpace() || self == "\n"
	}

}
