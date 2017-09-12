import XCTest

class FormatTest: XCTestCase {

    func formatAlign(res: String, expect: String) {
        Indent.char = "    "
        let preferences = Preferences()
        preferences.areParametersAligned = true
        let parser = SwiftParser(string: res, preferences: preferences)
        format(parser: parser, expect: expect)
    }

    func formatNonAlign(res: String, expect: String) {
        Indent.char = "    "
        let preferences = Preferences()
        preferences.areParametersAligned = false
        let parser = SwiftParser(string: res, preferences: preferences)
        format(parser: parser, expect: expect)
    }

    func format(parser: SwiftParser, expect: String) {
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
        formatAlign(res: res, expect: res)
        formatNonAlign(res: res, expect: res)
    }

    func testCase2() { //#151
        let res = "UIView.animate(withDuration: 0.3, animations: {\n"
            + "    someCode()\n"
            + "}) { finished in\n"
            + "    afterAnimation()\n"
            + "}"
        formatAlign(res: res, expect: res)
        formatNonAlign(res: res, expect: res)
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
        formatAlign(res: res, expect: res)
    }

    func testCase4() { //#152
        let res = "\nswitch aEnum {\n"
            + "case .value1,\n"
            + "     .value2:\n"
            + "    someCode()\n"
            + "}"
        formatAlign(res: res, expect: res)
        //        formatNonAlign(res: res, expect: res)
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
        formatAlign(res: res, expect: res)
        //        formatNonAlign(res: res, expect: res)
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

        formatAlign(res: res, expect: res)
        //        formatNonAlign(res: res, expect: res)
    }

    func testCase7() { // multi switch
        let res = "\nswitch a {\n"
            + "case 1:\n"
            + "    switch b {\n"
            + "    case 1:\n"
            + "        return\n"
            + "    default:\n"
            + "        return\n"
            + "    }\n"
            + "default:\n"
            + "    return\n"
            + "}\n"
        formatAlign(res: res, expect: res)
    }

    func testCase8() {
        let res = "a(\n"
            + "    a)\n"
            + "a(a,\n"
            + "  a)\n"
        formatAlign(res: res, expect: res)
    }

    func testCase9() { //#155
        let res = "func some() {\n"
            + "    return f(\n"
            + "        arg1: value1,\n"
            + "        arg2: value2\n"
            + "    )\n"
            + "}\n"
        formatAlign(res: res, expect: res)
        formatNonAlign(res: res, expect: res)
    }

    func testCase10() { //#164
        let res = "a( b: c)"
        let result = "a(b: c)"
        formatAlign(res: res, expect: result)
        formatNonAlign(res: res, expect: result)
    }

    func testCase11() { //#163
        let res = "a ? (b as? Int) : Int((c as? Double) ?? 0)"
        formatAlign(res: res, expect: res)
        formatNonAlign(res: res, expect: res)
    }

    func testCase12() { //#166
        let res = "c = a + b;"
        let ret = "c = a + b"
        let parser = SwiftParser(string: res)
        parser.autoRemoveChar = true
        format(parser: parser, expect: ret)
    }

    func testCase13() {
        let res = "\"\"\"  a   b  \"\"\""
        let ret = "\"\"\"  a   b  \"\"\""
        let parser = SwiftParser(string: res)
        format(parser: parser, expect: ret)
    }

    func testCase14() {
        let res =
            "if a == 1 {\n"
                + "    a = 2\n"
                + "}\n"
                + "else {\n"
                + "    a = 3\n"
                + "}"
        
        formatAlign(res: res, expect: res)
        let res2 =
            "guard let a = a\n"
                + "    else { return }"
        
        formatAlign(res: res2, expect: res2)
        
    }
}
