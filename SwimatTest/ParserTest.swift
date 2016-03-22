import XCTest
import Foundation

class ParserTest: XCTestCase {

	func testNext() {
		let parser = Parser()

		parser.strIndex = 1
		parser.string = "abcde"
		assert(parser.isNext("bcde") == true)
		assert(parser.isNext("bde") == false)

		parser.strIndex = 2
		assert(parser.isNext("cdef") == false)

		parser.strIndex = 5
		assert(parser.isNext("a") == false)
	}
}
