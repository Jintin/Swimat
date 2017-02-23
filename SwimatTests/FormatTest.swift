import XCTest

class FormatTest: XCTestCase {

    func format(res: String, expect: String) {
        Indent.char = "    "
        Indent.size = 4
        Indent.paraAlign = true
        let parser = SwiftParser(string: res)
        do {
            let result = try parser.format()
            print("expect=")
            print(expect)
            print("result=")
            print(result)
            assert(result == expect)
        } catch {
            assertionFailure()
        }
    }

    func formatAlign(res: String, expect: String) {
        Indent.char = "    "
        Indent.size = 4
        Indent.paraAlign = false
        let parser = SwiftParser(string: res)
        do {
            let result = try parser.format()
            print("expect=")
            print(expect)
            print("result=")
            print(result)
            assert(result == expect)
        } catch {
            assertionFailure()
        }
    }

    func testCase1() { //#151
        let res = "UIView.animatesss(withDuration: 0.3, animations: {\n"
            + "    someCode()\n"
            + "})"
        format(res: res, expect: res)
        formatAlign(res: res, expect: res)
    }

    func testCase2() { //#151
        let res = "UIView.animate(withDuration: 0.3, animations: {\n"
            + "    someCode()\n"
            + "}) { finished in\n"
            + "    afterAnimation()\n"
            + "}"
        format(res: res, expect: res)
        formatAlign(res: res, expect: res)
    }

    func testCase3() { //#147
        let res = "\nlet chain = UIView.animateAndChain(withDuration: 1.0,\n"
            + "                                   delay: 2.0,\n"
            + "                                   options: .curveEaseInOut,\n"
            + "                                   animations: {\n"
            + "                                       slideHideTitle()\n"
            + "                                       self.view.layoutIfNeeded()\n"
            + "                                   },\n"
            + "                                   completion: nil)"
        format(res: res, expect: res)
    }

    func testCase4() { //#152
        let res = "\nswitch aEnum {\n"
            + "case .value1,\n"
            + "     .value2:\n"
            + "    someCode()\n"
            + "}"
        format(res: res, expect: res)
        //        formatAlign(res: res, expect: res)
    }

    func testCase5() { //#153
        //        a
        //            .map { (i) in
        //                i * 2
        //        }
        let res = "a\n"
            + "    .map { (i) in\n"
            + "        i * 2\n"
            + "}"
        format(res: res, expect: res)
        //        formatAlign(res: res, expect: res)
    }

    func testCase6() { //#150
        //        if let a =
        //            b, c == d {
        //            a + c
        //        }
        let res = "if let a = b,\n"
            + "    c == d {\n"
            + "    a = c\n"
            + "}"
        format(res: res, expect: res)
        //        formatAlign(res: res, expect: res)
    }

}
