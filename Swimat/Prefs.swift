import Foundation

class Prefs {

	private static let Indent = "indent"
	private static let IndentDefault = "\t"
	static let IndentTitle = ["Tab Indent", "2 Space Indent", "3 Space Indent", "4 Space Indent"]
	static let IndentTable = ["Tab Indent": "\t", "2 Space Indent": "  ", "3 Space Indent": "   ", "4 Space Indent": "    "]
	private static let SaveTrigger = "save_trigger"
	private static let IndentEmptyLine = "indent_emptyline"
	private static let SmartLine = "smart_line"

	static func setIndent(indent: String) {
		setString(Indent, value: indent)
	}

	static func getIndent() -> String {
		return getString(Indent, defValue: IndentDefault)
	}

	static func saveTrigger(trigger: Bool) {
		setBool(SaveTrigger, value: trigger)
	}

	static func isSaveTrigger() -> Bool {
		return getBool(SaveTrigger, defValue: false)
	}

	static func indentEmptyLine(trigger: Bool) {
		setBool(IndentEmptyLine, value: trigger)
	}

	static func isIndentEmptyLine() -> Bool {
		return getBool(IndentEmptyLine, defValue: false)
	}

	static func setSmartLine(value: Bool) {
		setBool(SmartLine, value: value)
	}

	static func isSmartLine() -> Bool {
		return getBool(SmartLine, defValue: false)
	}

}

extension Prefs { // MARK: base function

	static func getBool(tag: String, defValue: Bool) -> Bool {
		let userDefault = NSUserDefaults.standardUserDefaults()
		return userDefault.boolForKey(tag) ?? defValue
	}

	static func setBool(tag: String, value: Bool) {
		let userDefault = NSUserDefaults.standardUserDefaults()
		userDefault.setBool(value, forKey: tag)
	}

	static func getString(tag: String, defValue: String) -> String {
		let userDefault = NSUserDefaults.standardUserDefaults()
		return userDefault.stringForKey(tag) ?? defValue
	}

	static func setString(tag: String, value: String) {
		let userDefault = NSUserDefaults.standardUserDefaults()
		userDefault.setObject(value, forKey: tag)
	}

}
