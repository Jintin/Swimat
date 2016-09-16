import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    func performCommandWithInvocation(invocation: XCSourceEditorCommandInvocation, completionHandler: (NSError?) -> Void) {

        var indent = ""
        if invocation.buffer.usesTabsForIndentation {
            indent = "\t"
        } else {
            indent = String(count: invocation.buffer.indentationWidth, repeatedValue: " " as Character)
        }

        let parser = SwiftParser(string: invocation.buffer.completeBuffer, indentChar: indent)
        do {
            let result = try parser.format()
            invocation.buffer.lines[0] = result.string
            completionHandler(nil)
        } catch {
            completionHandler(error as NSError)
        }
    }

}

