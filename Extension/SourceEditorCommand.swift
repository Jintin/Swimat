import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation,
                 completionHandler: @escaping (Error?) -> Void) {

        let uti = invocation.buffer.contentUTI
        guard uti == "com.apple.dt.playground" || uti == "public.swift-source" || uti == "com.apple.dt.playgroundpage" else {
            completionHandler(nil)
            return
        }

        if invocation.buffer.usesTabsForIndentation {
            Indent.char = "\t"
        } else {
            Indent.char = String(repeating: " ", count: invocation.buffer.indentationWidth)
        }

        let parser = SwiftParser(string: invocation.buffer.completeBuffer)
        do {
            let newLines = try parser.format().components(separatedBy: "\n")
            let lines = invocation.buffer.lines
            let selections = invocation.buffer.selections
            var hasSelection = false

            func updateLine(index: Int) {
                guard index < newLines.count, index < lines.count else {
                    return
                }
                if let line = lines[index] as? String {
                    let newLine = newLines[index] + "\n"
                    if newLine != line {
                        lines[index] = newLine
                    }
                }
            }

            for i in 0 ..< selections.count {
                if let selection = selections[i] as? XCSourceTextRange, selection.start != selection.end {
                    hasSelection = true
                    for j in selection.start.line...selection.end.line {
                        updateLine(index: j)
                    }
                }
            }
            if !hasSelection {
                for i in 0 ..< lines.count {
                    updateLine(index: i)
                }
            }

            completionHandler(nil)
        } catch {
            completionHandler(error as NSError)
        }
    }

}

extension XCSourceTextPosition: Equatable {

    public static func == (lhs: XCSourceTextPosition, rhs: XCSourceTextPosition) -> Bool {
        return lhs.column == rhs.column && lhs.line == rhs.line
    }

}
