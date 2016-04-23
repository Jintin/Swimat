import XCTest

class SwimatTest: XCTestCase {

	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testPerformanceExample() {
		var string = "abcdddd"
		var string2 = "abcdddd "

		for _ in 0 ... 100000 {
			string += "a cb fe"
			string2 += "a cb fe"

		}
		// This is an example of a performance test case.
		self.measureBlock {
			// Put the code you want to measure the time of here.

			for _ in 0 ... 100000 {
				string.trim1()
				string2.trim1()
			}
		}
	}

	func trim1() {
		// This is an example of a performance test case.
		self.measureBlock {
			// Put the code you want to measure the time of here.
			let string = "abcdddd"
			let string2 = "abcdddd "

			for _ in 0 ... 100 {
				string.trim1()
				string2.trim1()
			}
		}
	}

	func trim2() {
		// This is an example of a performance test case.
		self.measureBlock {
			// Put the code you want to measure the time of here.
			let string = "abcdddd"
			let string2 = "abcdddd "
			for _ in 0 ... 100 {
				string.trim2()
				string2.trim2()
			}
		}
	}

}
