import Foundation

extension String {

    var last: Character {
        return last ?? "\0" as Character
    }

    func lastWord() -> String {
        if !isEmpty {
            let end = lastNonBlankIndex(endIndex)
            if end != startIndex || !self[end].isBlank() {
                let start = lastIndex(from: end) { $0.isBlank() }
                if self[start].isBlank() {
                    return String(self[index(after: start) ... end])
                }
                return String(self[start ... end])
            }
        }
        return ""
    }

    func trim() -> String {
        return trimmingCharacters(in: .whitespaces)
    }

    mutating func keepSpace() {
        if !last.isBlank() {
            append(" ")
        }
    }

    func nextIndex(from start: String.Index, checker: (Character) -> Bool) -> String.Index {
        var target = start
        while target < endIndex {
            if checker(self[target]) {
                break
            }
            target = index(after: target)
        }
        return target
    }

    func nextNonSpaceIndex(_ index: String.Index) -> String.Index {
        return nextIndex(from: index) { !$0.isSpace() }
    }

    func lastIndex(from: String.Index, checker: (Character) -> Bool) -> String.Index {
        var target = from
        while target > startIndex {
            target = index(before: target)
            if checker(self[target]) {
                break
            }
        }
        return target
    }

    func lastNonSpaceIndex(_ start: String.Index) -> String.Index {
        return lastIndex(from: start) { !$0.isSpace() }
    }

    func lastNonSpaceChar(_ start: String.Index) -> Character {
        return self[lastNonSpaceIndex(start)]
    }

    func lastNonBlankIndex(_ start: String.Index) -> String.Index {
        return lastIndex(from: start) { !$0.isBlank() }
    }

}
