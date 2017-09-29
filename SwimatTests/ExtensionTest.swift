import XCTest

class ExtensionTest: XCTestCase {

    // MARK: basic String
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

    func testNextIndex() {
        let a = "abc"
        assert(a.nextIndex(from: a.startIndex, checker: { $0 == "b" }) == a.index(after: a.startIndex))
        assert(a.nextIndex(from: a.startIndex, checker: { $0 == "c" }) == a.index(before: a.endIndex))
        assert(a.nextIndex(from: a.startIndex, checker: { $0 == "d" }) == a.endIndex)
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
        let a = "abcd"
        assert(a.lastIndex(from: a.endIndex, checker: { $0 == "a" }) == a.startIndex)
        assert(a.lastIndex(from: a.endIndex, checker: { $0 == "b" }) == a.index(after: a.startIndex))
        assert(a.lastIndex(from: a.endIndex, checker: { $0 == "d" }) == a.index(before: a.endIndex))
        assert(a.lastIndex(from: a.endIndex, checker: { $0 == "e" }) == a.startIndex)
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

    func testParentheses() {
        let a = "(a+b(c-d(\"e  f\")))"
        do {
            let result = try a.findParentheses(from: a.startIndex)
            assert(result == ("(a + b(c - d(\"e  f\")))", a.endIndex))
        } catch {
            assertionFailure()
        }
    }

    func testSquare() {
        let a = "[a+b,c(d-e)]"
        do {
            let result = try a.findSquare(from: a.startIndex)
            assert(result == ("[a + b, c(d - e)]", a.endIndex))
        } catch {
            assertionFailure()
        }
    }

    func testQuote() {
        let a = "\"a+b\\(c+d)\""
        do {
            let result = try a.findQuote(from: a.startIndex)
            assert(result == ("\"a+b\\(c + d)\"", a.endIndex))
        } catch {
            assertionFailure()
        }
    }

    func testTernary() {
        do {
            let a = "?bb:cc"
            if let result = try a.findTernary(from: a.startIndex) {
                assert(result == ("? bb : cc", a.endIndex))
            } else {
                assertionFailure()
            }
        } catch {
            assertionFailure()
        }
    }

    func testStatement() {
        do {
            let a = "aa+bb"
            if let result = try a.findStatement(from: a.startIndex) {
                assert(result == ("aa + bb", a.endIndex))
            } else {
                assertionFailure()
            }
        } catch {
            assertionFailure()
        }
    }

    func testGeneric() {
        let values = [
            "<A,B<C,D>>": "<A, B<C, D>>",
            "<A, B<C, D>>": "<A, B<C, D>>"]
        for (a, b) in values {
            do {
                if let result = try a.findGeneric(from: a.startIndex) {
                    assert(result == (string: b, index: a.endIndex))
                } else {
                    assertionFailure()
                }
            } catch {
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
