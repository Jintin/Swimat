import Foundation

extension NSDocument {

	func mySaveDocument(sender: AnyObject?) {
		if Prefs.isSaveTrigger() {
			Swimat(bundle: NSBundle()).formatAction()
		}
		mySaveDocument(sender)
	}

}
