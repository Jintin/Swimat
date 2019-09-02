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

    func testBlock() throws {
        let pareText = "(a+b(c-d(\"e  f\")))"
        let pare = try pareText.findParentheses(from: pareText.startIndex)
        assert(pare == ("(a + b(c - d(\"e  f\")))", pareText.endIndex))

        let squareText = "[a+b,c(d-e)]"
        let square = try squareText.findSquare(from: squareText.startIndex)
        assert(square == ("[a + b, c(d - e)]", squareText.endIndex))
    }

    func testQuote() throws {
        let quote = "\"a+b\\(c+d)\""
        let result = try quote.findQuote(from: quote.startIndex)
        assert(result == ("\"a+b\\(c + d)\"", quote.endIndex))
    }

    func testTernary() throws {
        let ternary = "?bb:cc"
        if let result = ternary.findTernary(from: ternary.startIndex) {
            assert(result == ("? bb : cc", ternary.endIndex))
        } else {
            assertionFailure()
        }
    }

    func testStatement() throws {
        let statement = "aa+bb"
        if let result = statement.findStatement(from: statement.startIndex) {
            assert(result == ("aa + bb", statement.endIndex))
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
