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
			let end = lastNonBlankIndex(endIndex)
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
//		var index = endIndex.predecessor()
//		while self[index].isSpace() {
//
//			removeAtIndex(index)
//			if index > startIndex {
//				index = index.predecessor()
//			}
//		}

//		if let last = lastChar {
//			if last.isSpace() {
		return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//			}
//		}
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

	func isOneOf(list: [Character]) -> Bool {
		return list.contains(self)
	}
}

func == <T: Equatable> (tuple1: (T, T), tuple2: (T, T)) -> Bool {
	return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}