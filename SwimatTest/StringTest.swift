import XCTest
import Swimat

class StringTest: XCTestCase {

	func testDiff() {
		var diff = "abcd".findDiff("abce")
		print(diff)
		assert(diff == (start: 3, end: 0))

		diff = "acd".findDiff("abcd")
		print(diff)
		assert(diff == (start: 1, end: 2))

		diff = "abcd".findDiff("dbca")
		print(diff)
		assert(diff == (start: 0, end: 0))
	}
}

func == <T: Equatable> (tuple1: (T, T), tuple2: (T, T)) -> Bool
{
	return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}
