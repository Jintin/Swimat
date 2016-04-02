import XCTest
import Foundation

class StringTest: XCTestCase {

	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measureBlock {
			// Put the code you want to measure the time of here.
			for _ in 1 ... 10 {
				self.testDiff()
			}
		}
	}

	func testRange() {
		assert("abcde"[1] == "b")
		assert("abcde"[1 ... 3] == "bcd")
		assert("abcde"[1 ..< 4] == "bcd")
	}

	func testTrim() {
		assert(" abc ".trim() == "abc")
		assert("\tabc\t".trim() == "abc")
		assert("\nabc\n".trim() == "\nabc\n")
	}

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

		diff = "abcd".findDiff("abcd")
		print(diff)
		assert(diff == (start: 3, end: 1))
	}
}
