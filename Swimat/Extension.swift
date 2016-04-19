import Foundation

extension String {
	var count: Int {
		get {
			return characters.count
		}
	}
	
	var lastChar: Character? {
		get {
			return characters.last
		}
	}
	
	func lastWord() -> String {
		if count > 0 {
			let end = lastNonBlankIndex(endIndex.predecessor())
			if end != startIndex || !self[end].isBlank() {
				let start = lastIndex(end) { self[$0].isBlank() }
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
		if self.isEmpty || string.isEmpty {
			return nil
		}
		
		let start = commonPrefixWithString(string, options: .AnchoredSearch).endIndex
		var end1 = endIndex.predecessor()
		var end2 = string.endIndex.predecessor()
		while self[end1] == string[end2] {
			if end1 >= start && end2 >= start {
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
			print("diff    executionTime = \(executionTime)");
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
				let to = String.Index(to16, within: self) {
					return from ..< to
			}
		}
		return nil
	}
	
	func nsRangeFromRange(strRange: Range<String.Index>?) -> NSRange? {
		if let range = strRange {
			let utf16view = self.utf16
			
			let from = String.UTF16View.Index(range.startIndex, within: utf16view)
			let to = String.UTF16View.Index(range.endIndex, within: utf16view)
			
			return NSMakeRange(utf16view.startIndex.distanceTo(from), from.distanceTo(to))
		}
		return nil
	}
	
	func nextIndex(start: String.Index, checker: String.Index -> Bool) -> String.Index {
		var index = start
		while index < endIndex {
			if checker(index) {
				break
			}
			index = index.successor()
		}
		return index
	}
	
	func nextNonSpaceIndex(index: String.Index) -> String.Index {
		return nextIndex(index) { !self[$0].isSpace() }
	}
	
	func lastIndex(start: String.Index, checker: String.Index -> Bool) -> String.Index {
		var index = start
		while index > startIndex {
			if checker(index) {
				break
			}
			index = index.predecessor()
		}
		return index
	}
	
	func lastNonSpaceIndex(start: String.Index) -> String.Index {
		return lastIndex(start) { !self[$0].isSpace() }
	}
	
	func lastNonSpaceChar(start: String.Index) -> Character {
		return self[lastNonSpaceIndex(start)]
	}
	
	func lastNonBlankIndex(start: String.Index) -> String.Index {
		return lastIndex(start) { !self[$0].isBlank() }
	}
}

extension String {
	func findBlock(start: String.Index) -> (string: String, index: String.Index) {
		var index = start.successor()
		var result = "("
		while index < self.endIndex {
			let next = self[index]
			
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
		while index < self.endIndex {
			let next = self[index]
			
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
		return (result, self.endIndex.predecessor())
	}
	
	func findTenary(index: String.Index) -> (string: String, index: String.Index)? {
		let start = self.nextNonSpaceIndex(index.successor())
		guard let first = findObject(start) else {
			return nil
		}
		let middle = self.nextNonSpaceIndex(first.index)
		guard self[middle] == ":" else {
			return nil
		}
		let end = self.nextNonSpaceIndex(middle.successor())
		guard let second = findObject(end) else {
			return nil
		}
		return ("? \(first.string) : \(second.string)", second.index)
	}
	
	func findObject(start: String.Index) -> (string: String, index: String.Index)? {
		var index = start
		var result = ""
		while index < self.endIndex {
			let next = self[index]
			let list: [Character] = ["?", "!", "."]
			if next.isAZ() || list.contains(next) { // TODO check complex case
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
		while index < self.endIndex {
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