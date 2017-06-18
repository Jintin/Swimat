import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    func perform(with invocation: XCSourceEditorCommandInvocation,
                 completionHandler: @escaping (Error?) -> Swift.Void) {

        let uti = invocation.buffer.contentUTI
        if uti != "com.apple.dt.playground" && uti != "public.swift-source" {
            completionHandler(nil)
        }

        if invocation.buffer.usesTabsForIndentation {
            Indent.char = "\t"
            Indent.size = 1
        } else {
            Indent.char = String(repeating: " ", count: invocation.buffer.indentationWidth)
            Indent.size = invocation.buffer.indentationWidth
        }
        Indent.paraAlign = Pref.isParaAlign()

        let parser = SwiftParser(string: invocation.buffer.completeBuffer)
        parser.autoRemoveChar = Pref.isAutoRemoveChar()
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
                    for j in selection.start.line ... selection.end.line {
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

extension XCSourceTextPosition {

    static func != (left: XCSourceTextPosition, right: XCSourceTextPosition) -> Bool {
        if left.column != right.column || left.line != right.line {
            return true
        }
        return false
    }

}
