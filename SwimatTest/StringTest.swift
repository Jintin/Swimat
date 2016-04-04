import XCTest
import Foundation

class StringTest: XCTestCase {

//	func testRange() {
//		assert("abcde"[1] == "b")
//		assert("abcde"[1 ... 3] == "bcd")
//		assert("abcde"[1 ..< 4] == "bcd")
//	}

	func testTrim() {
		assert(" abc ".trim() == "abc")
		assert("\tabc\t".trim() == "abc")
		assert("\nabc\n".trim() == "\nabc\n")
	}

	func testDiff() {
		let string = "abcd"
		func index(start: Int, end1: Int, end2: Int) -> (range1: Range<String.Index>, range2: Range<String.Index>) {
			let range1 = string.startIndex.advancedBy(start) ..< string.startIndex.advancedBy(end1)
			let range2 = string.startIndex.advancedBy(start) ..< string.startIndex.advancedBy(end2)

			return (range1, range2)
		}

		var diff = string.findDiff("abce")
		assert(diff! == index(3, end1: 4, end2: 4))

		diff = "acd".findDiff(string)
		assert(diff! == index(1, end1: 1, end2: 2))

		diff = string.findDiff("acd")
		assert(diff! == index(1, end1: 2, end2: 1))

		diff = string.findDiff(string)
		assert(diff == nil)
	}
}
