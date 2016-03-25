import XCTest
import Foundation

class StringTest: XCTestCase {

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
	}
}
