import Foundation

enum IndentType: Character {
    case parentheses = "(", square = "[", curly = "{"
}

class Indent {
    static var char: String = ""
    static var size: Int = 0
    var count: Int // general indent count
    var extra: Int // from extra indent
    var indentAdd: Bool // same line flag, if same line add only one indent
    var extraAdd: Bool
    var leading: Int // leading for smart align
    var inSwitch: Bool // is in switch block
    var block: IndentType

    init() {
        count = 0
        extra = 0
        indentAdd = false
        extraAdd = false
        leading = 0
        inSwitch = false
        block = .curly
    }

    init(with indent: Indent, offset: Int, type: IndentType?) {
        self.block = type ?? .curly
        self.count = indent.count
        self.extra = indent.extra
        if block == .curly {
            self.leading = 0
            self.inSwitch = indent.inSwitch
        } else {
            self.leading = indent.leading
            self.inSwitch = false
        }

        if self.block != .parentheses && !indent.indentAdd {
            self.count += 1
            self.indentAdd = true
        } else {
            self.indentAdd = indent.indentAdd
        }
        if !indent.extraAdd {
            self.count += indent.extra
            self.extraAdd = true
        } else {
            self.extraAdd = false
        }
        if self.block == .parentheses {
            self.leading = offset - self.count * Indent.size - 1
            if self.leading < 0 {
                self.leading = 0
            }
        }
    }

}
