import XCTest

class ExtensionTest: XCTestCase {

    // MARK: basic String
    func testLastWord() {
        let values = [
            "": "",
            " ab": "ab",
            " ab ": "ab",
            " ab cd": "cd",
            " ab cd  ": "cd",
        ]
        for (a, b) in values {
            assert(a.lastWord() == b)
        }
    }

    func testNextIndex() {
        let text = "abc"
        let values: [Character: String.Index] = [
            "b": text.index(after: text.startIndex),
            "c": text.index(before: text.endIndex),
            "d": text.endIndex
        ]
        for (a, b) in values {
            let index = text.nextIndex(from: text.startIndex) { $0 == a }
            assert(index == b)
        }
    }

    func testNextNonSpaceIndex() {
        let a = " abc"
        assert(a.nextNonSpaceIndex(a.startIndex) == a.index(after: a.startIndex))
        let b = "abc"
        assert(b.nextNonSpaceIndex(a.startIndex) == b.startIndex)
        let c = "   "
        assert(c.nextNonSpaceIndex(a.startIndex) == c.endIndex)
    }

    func testLastIndex() {
        let text = "abcd"
        let values: [Character: String.Index] = [
            "a": text.startIndex,
            "b": text.index(after: text.startIndex),
            "d": text.index(before: text.endIndex),
            "e": text.startIndex
        ]
        for (a, b) in values {
            let index = text.lastIndex(from: text.endIndex) { $0 == a }
            assert(index == b)
        }
    }

    func testLastNonSpaceIndex() {
        let a = "ab "
        assert(a.lastNonSpaceIndex(a.endIndex) == a.index(after: a.startIndex))
        let b = "abc"
        assert(b.lastNonSpaceIndex(a.endIndex) == b.index(before: b.endIndex))
    }

    func testLastNonSpaceChar() {
        let a = "ab "
        assert(a.lastNonSpaceChar(a.endIndex) == "b")
    }

    func testLastNonBlankIndex() {
        let a = "ab\n "
        assert(a.lastNonBlankIndex(a.endIndex) == a.index(after: a.startIndex))
    }

    func testParentheses() throws {
        let a = "(a+b(c-d(\"e  f\")))"
        let result = try a.findParentheses(from: a.startIndex)
        assert(result == ("(a + b(c - d(\"e  f\")))", a.endIndex))
    }

    func testSquare() throws {
        let a = "[a+b,c(d-e)]"
        let result = try a.findSquare(from: a.startIndex)
        assert(result == ("[a + b, c(d - e)]", a.endIndex))
    }

    func testQuote() throws {
        let a = "\"a+b\\(c+d)\""
        let result = try a.findQuote(from: a.startIndex)
        assert(result == ("\"a+b\\(c + d)\"", a.endIndex))
    }

    func testTernary() throws {
        let a = "?bb:cc"
        if let result = try a.findTernary(from: a.startIndex) {
            assert(result == ("? bb : cc", a.endIndex))
        } else {
            assertionFailure()
        }
    }

    func testStatement() throws {
        let a = "aa+bb"
        if let result = try a.findStatement(from: a.startIndex) {
            assert(result == ("aa + bb", a.endIndex))
        } else {
            assertionFailure()
        }
    }

    func testGeneric() throws {
        let values = [
            "<A,B<C,D>>": "<A, B<C, D>>",
            "<A, B<C, D>>": "<A, B<C, D>>"]
        for (a, b) in values {
            if let result = try a.findGeneric(from: a.startIndex) {
                assert(result == (string: b, index: a.endIndex))
            } else {
                assertionFailure()
            }
        }
    }

    // MARK: basic char
    func testIsAZ() {
        let values = [
            "a" as Character: true,
            "=" as Character: false]
        for (a, b) in values {
            assert(a.isAZ() == b)
        }
    }

}
