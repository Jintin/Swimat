import XCTest
import Foundation

class StringTest: XCTestCase {

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

		var diff = "abcd".findDiff("abce")
		assert(diff! == index(3, end1: 4, end2: 4))

		diff = "acd".findDiff("abcd")
		assert(diff! == index(1, end1: 1, end2: 2))

		diff = "abcd".findDiff("acd")
		assert(diff! == index(1, end1: 2, end2: 1))

		diff = "abcd".findDiff("abcd")
		assert(diff == nil)
	}

	func testLastWord() {
		assert("".lastWord() == "")
		assert(" ".lastWord() == "")
		assert("a".lastWord() == "a")
		assert("a ".lastWord() == "a")
		assert(" a".lastWord() == "a")
		assert("aa ".lastWord() == "aa")
		assert("\naa\n".lastWord() == "aa")
	}
	
	func testNextIndex() {
		
	}
}
