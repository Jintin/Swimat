import Foundation

extension String {
	subscript(i: Int) -> Character {
		return self[startIndex.advancedBy(i)]
	}

	subscript(r: Range<Int>) -> String {

		let start = startIndex.advancedBy(r.startIndex)
		let end = startIndex.advancedBy(r.endIndex)
		return self[start ..< end]
	}

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

	func findDiff(string: String) -> (start: Int, end: Int) {
		let methodStart = NSDate()
		if self.isEmpty || string.isEmpty {
			return (0, 0)
		}

		var start = 0
		var end = 0
		var startIndex = self.startIndex
		var end1 = endIndex.predecessor()
		var end2 = string.endIndex.predecessor()

		let limit = min(end1, end2)

		while self[startIndex] == string[startIndex] {
			if startIndex < limit {
				startIndex = startIndex.successor()
				start += 1
			} else {
				break
			}
		}

		while self[end1] == string[end2] {
			if end1 >= startIndex && end2 >= startIndex {
				end1 = end1.predecessor()
				end2 = end2.predecessor()
				end += 1
			} else {
				break
			}
		}

		let executionTime = NSDate().timeIntervalSinceDate(methodStart)
		print("diff executionTime = \(executionTime)");

		return (start, end)
	}

	func isSymbol() -> Bool {
		let symbol = ["+", "-", "*"]
		return symbol.contains(self)
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

	func nextNonSpaceIndex(start: String.Index) -> String.Index {
		return nextIndex(start) {
			index -> Bool in
			let char = self[index]
			return !char.isSpace()
		}
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