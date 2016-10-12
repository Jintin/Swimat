import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Swift.Void) {

        let uti = invocation.buffer.contentUTI
        if uti != "com.apple.dt.playground" && uti != "public.swift-source" {
            completionHandler(nil)
        }

        if invocation.buffer.usesTabsForIndentation {
            SwiftParser.indentChar = "\t"
            SwiftParser.indentSize = 1
        } else {
            SwiftParser.indentChar = String(repeating: " ", count: invocation.buffer.indentationWidth)
            SwiftParser.indentSize = invocation.buffer.indentationWidth
        }

        let parser = SwiftParser(string: invocation.buffer.completeBuffer)
        do {
            let newLines = try parser.format().components(separatedBy: "\n")
            let lines = invocation.buffer.lines
            for i in 0 ..< lines.count {
                if let line = lines[i] as? String {
                    let newLine = newLines[i] + "\n"
                    if newLine != line {
                        lines[i] = newLine
                    }
                }
            }
            completionHandler(nil)
        } catch {
            completionHandler(error as NSError)
        }
    }

}
