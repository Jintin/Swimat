import XCTest

class FormatTest: XCTestCase {
    class func generateTests() {
        // Add formatting tests
        let bundle = Bundle(for: FormatTest.self)
        // For whatever reason, urls(forResourcesWithExtension:subdirectory:)
        // doesn't seem to be working properly
        let tests = bundle.paths(forResourcesOfType: "", inDirectory: "tests").map(URL.init(fileURLWithPath:))
        for test in tests {
            let fullTestName = test.lastPathComponent
            let testName: String
            // Drop the leading number and dash, if any
            if let index = fullTestName.index(of: "-") {
                testName = String(fullTestName[fullTestName.index(after: index)..<fullTestName.endIndex])
            } else {
                testName = fullTestName
            }
            guard let before = try? String(contentsOf: test.appendingPathComponent("before.swift")),
                let after = try? String(contentsOf: test.appendingPathComponent("after.swift")),
                let preferencesData = try? Data(contentsOf: test.appendingPathComponent("preferences.json")),
                let preferences = try? JSONDecoder().decode(Preferences.self, from: preferencesData) else {
                    fatalError("Could not parse test format for \(fullTestName)")
            }
            addInstanceMethod(named: Selector("test-\(testName)"), to: FormatTest.self) {
                let parser = SwiftParser(string: before, preferences: preferences)
                guard let result = try? parser.format() else {
                    fatalError("Formatter threw an exception")
                }

                XCTAssertEqual(result, after, "result: \n\(result)\nafter: \n\(after)")
            }
        }

        // Set the indent size
        Indent.char = "    "
    }
}
