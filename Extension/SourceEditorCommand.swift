import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Swift.Void) {

        if invocation.buffer.usesTabsForIndentation {
            SwiftParser.indentChar = "\t"
        } else {
            SwiftParser.indentChar = String(repeating: " ", count: invocation.buffer.indentationWidth)
        }

        let parser = SwiftParser(string: invocation.buffer.completeBuffer)
        do {
            let result = try parser.format()
            let lines = result.components(separatedBy: "\n")
            for i in 0 ..< invocation.buffer.lines.count {
                if let line = invocation.buffer.lines[i] as? String {
                    if lines[i] + "\n" != line {
                        invocation.buffer.lines[i] = lines[i] + "\n"
                    }
                }
            }
            completionHandler(nil)
        } catch {
            completionHandler(error as NSError)
        }
    }

}
