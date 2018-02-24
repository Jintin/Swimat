import Foundation

extension Character {

    func isAZ() -> Bool {
        if self >= "a" && self <= "z" {
            return true
        } else if self >= "A" && self <= "Z" {
            return true
        } else if self >= "0" && self <= "9" {
            return true
        }
        return false
    }

    func isOperator() -> Bool {
        return self == "+" || self == "-" || self == "*" || self == "/" || self == "%"
    }

    func isUpperBlock() -> Bool {
        return self == "{" || self == "[" || self == "("
    }

    func isLowerBlock() -> Bool {
        return self == "}" || self == "]" || self == ")"
    }

    func isSpace() -> Bool {
        return self == " " || self == "\t"
    }

    func isBlank() -> Bool {
        return isSpace() || self == "\n"
    }

}
