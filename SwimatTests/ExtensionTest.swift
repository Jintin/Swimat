import XCTest

class ExtensionTest: XCTestCase {

//    extension String
    func testLastWord() {
        let a = ""
        assert(a.lastWord() == "")
        let b = " ab"
        assert(b.lastWord() == "ab")
        let c = " ab  "
        assert(c.lastWord() == "ab")
        let d = " ab cd"
        assert(d.lastWord() == "cd")
        let e = " ab cd  "
        assert(e.lastWord() == "cd")
    }

    func testNextStringIndex() {

    }

    func testIsAZ() {
        measure() {
            let a: Character = "a"
            assert(a.isAZ() == true)
            let b: Character = "="
            assert(b.isAZ() == false)
        }
    }

}
