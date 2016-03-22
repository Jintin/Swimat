import Foundation

extension String {

	subscript(i: Int) -> String {
		if i < self.count {
			return String(self[self.startIndex.advancedBy(i)])
		} else {
			return ""
		}
	}

	subscript(r: Range<Int>) -> String {
		let start = startIndex.advancedBy(r.startIndex)
		let end = start.advancedBy(r.endIndex - r.startIndex)
		return self[start ..< end]
	}

	var count: Int {
		get {
			return self.characters.count
		}
	}

	func trim() -> String {
		return stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
	}

	func findDiff(string: String) -> (start: Int, end: Int) {
		var start = 0
		var end = 0
		let minValue = min(self.count, string.count)
		if minValue == 0 {
			return (0, 0)
		}
		while self[start] == string[start] {
			if start < minValue - 1 {
				start += 1
			} else {
				break
			}
		}
		while self[self.count - end - 1] == string[string.count - end - 1] {
			if minValue - end - 1 >= start {
				end += 1
			} else {
				break
			}
		}
		return (start, end)
	}
}

func == <T: Equatable> (tuple1: (T, T), tuple2: (T, T)) -> Bool
{
	return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}