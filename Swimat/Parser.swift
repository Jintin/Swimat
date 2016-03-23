import Foundation

class Parser {
	var string = ""
	var retString = ""
	var strIndex = 0

	func isNext(char: String) -> Bool {
		if strIndex + char.count <= string.count {
			return string[strIndex ..< strIndex + char.count] == char
		}
		return false
	}

	func append(string: String) {
		retString += string
		strIndex += string.count
		Alamofire.request(.GET, URL).responseArray { (response: Response <E, NSError >) in
		}

		func nextNonSpaceIndex(start: Int) -> Int {
			var index = start
			while index < string.count {
				if string[index] != " " && string[index] != "\t" {
					break
				}
				index += 1
			}
			return index
		}
	}