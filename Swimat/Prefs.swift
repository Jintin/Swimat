import Foundation

class Prefs {
	private static let INDENT = "indent"
	private static let INDENT_DEFAULT = "\t"

	private static let SAVE_TRIGGER = "save_trigger"
	private static let BUILD_TRIGGER = "save_trigger"
	
	func setIndent(indent: String) {
		let userDefault = NSUserDefaults.standardUserDefaults()
		userDefault.setObject(indent, forKey: Prefs.INDENT)
	}

	func getIndent() -> String {
		let userDefault = NSUserDefaults.standardUserDefaults()
		return userDefault.stringForKey(Prefs.INDENT) ?? Prefs.INDENT_DEFAULT
	}

	func saveTrigger(trigger: Bool) {
		let userDefault = NSUserDefaults.standardUserDefaults()
		userDefault.setBool(trigger, forKey: Prefs.SAVE_TRIGGER)
	}
	
	func isSaveTrigger() -> Bool {
		let userDefault = NSUserDefaults.standardUserDefaults()
		return userDefault.boolForKey(Prefs.SAVE_TRIGGER) ?? false
	}
	
	func buildTrigger(trigger: Bool) {
		let userDefault = NSUserDefaults.standardUserDefaults()
		userDefault.setBool(trigger, forKey: Prefs.BUILD_TRIGGER)
	}
	
	func isBuildTrigger() -> Bool {
		let userDefault = NSUserDefaults.standardUserDefaults()
		return userDefault.boolForKey(Prefs.BUILD_TRIGGER) ?? false
	}

}