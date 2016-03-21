import Foundation

extension String {
	func findDiff(string: String) -> (start: Int, end: Int) {
		var start = 0
		var end = 0
		let minValue = min(characters.count, string.characters.count)
		if minValue == 0 {
			return (0, 0)
		}
		while self[startIndex.advancedBy(start)] == string[string.startIndex.advancedBy(start)] {
			if start < minValue - 1 {
				start++
			} else {
				break
			}
		}
		while self[endIndex.advancedBy(-end - 1)] == string[string.endIndex.advancedBy(-end - 1)] {
			if minValue - end - 1 >= start {
				end++
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