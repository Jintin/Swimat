import Foundation

extension String {
	func findDiff(string: String) -> (start: Int, end: Int) {
		var start = 0
		var end = 0
		let minValue = min(self.characters.count, string.characters.count)
		if minValue == 0 {
			return (0, 0)
		}
		while self[self.startIndex.advancedBy(start)] == string[string.startIndex.advancedBy(start)] {
			if start < minValue - 1 {
				start++
			} else {
				break
			}
		}
		while self[self.endIndex.advancedBy(-end - 1)] == string[string.endIndex.advancedBy(-end - 1)] {
			if minValue - end - 1 >= start {
				end++
			} else {
				break
			}
		}
		return (start, end)
	}
}