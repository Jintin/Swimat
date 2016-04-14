import XCTest
import Foundation

class ParserTest: XCTestCase {

	func testNextString() {
		let parser = SwiftParser(string: "abcde")

		parser.strIndex = parser.string.startIndex.advancedBy(1)
		assert(parser.isNextString("bcde") == true)
		assert(parser.isNextString("bcdf") == false)
		parser.strIndex = parser.string.startIndex
		assert(parser.isNextString("a") == true)
	}
}
