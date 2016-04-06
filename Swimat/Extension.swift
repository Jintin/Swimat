import Foundation

extension String {
//	subscript(i: Int) -> Character {
//		return self[startIndex.advancedBy(i)]
//	}
//
//	subscript(r: Range<Int >) -> String {
//
//		let start = startIndex.advancedBy(r.startIndex)
//		let end = startIndex.advancedBy(r.endIndex)
//		return self[start ..< end]
//	}

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

	func trim() -> String {
		return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	}

	func findDiff(string: String) -> (range1: Range<String.Index>, range2: Range<String.Index>)? {
		let methodStart = NSDate()
		if self.isEmpty || string.isEmpty {
			return nil
		}

		var start1 = startIndex
		var start2 = string.startIndex
		var end1 = endIndex.predecessor()
		var end2 = string.endIndex.predecessor()

		while self[start1] == string[start2] {
			if start1 < end1 && start2 < end2 {
				start1 = start1.successor()
				start2 = start2.successor()
			} else {
				break
			}
		}

		while self[end1] == string[end2] {
			if end1 >= start1 && end2 >= start2 {
				end1 = end1.predecessor()
				end2 = end2.predecessor()
			} else {
				break
			}
		}
		end1 = end1.successor()
		end2 = end2.successor()

		let executionTime = NSDate().timeIntervalSinceDate(methodStart)
		print("diff    executionTime = \(executionTime)");
		if start1 == end1 && start1 == end2 {
			return nil
		}
		return (start1 ..< end1, start2 ..< end2)
	}

	func rangeFromNSRange(nsRange: NSRange?) -> Range<String.Index>? {
		if let range = nsRange {
//			let from = startIndex.advancedBy(range.location)
//			let to = from.advancedBy(range.length)
//
//			return from ..< to

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
//			let loc = startIndex.distanceTo(range.startIndex)
//			let len = range.startIndex.distanceTo(range.endIndex)
//
//			return NSMakeRange(loc, len)

			let utf16view = self.utf16

			let from = String.UTF16View.Index(range.startIndex, within: utf16view)
			let to = String.UTF16View.Index(range.endIndex, within: utf16view)

			return NSMakeRange(utf16view.startIndex.distanceTo(from), from.distanceTo(to))
		}
		return nil
	}

	func isSymbol() -> Bool {
		let symbol = ["+", "-", "*"]
		return symbol.contains(self)
	}

	func nextIndex(start: String.Index, checker: String.Index -> Bool) -> String.Index {

//		for index in start ..< endIndex {
//			if checker(index) {
//				return index
//			}
//		}
//		return endIndex
		
		var index = start
		while index < endIndex {
			if checker(index) {
				break
			}
			index = index.successor()
		}
		return index
	
	}

	func nextNonSpaceIndex(start: String.Index) -> String.Index {
		return nextIndex(start) { !self[$0].isSpace() }
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
}

extension Character {
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

func == <T: Equatable> (tuple1: (T, T), tuple2: (T, T)) -> Bool {
	return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}