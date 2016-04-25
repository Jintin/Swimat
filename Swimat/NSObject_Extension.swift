import Foundation

extension NSObject {

	class func pluginDidLoad(bundle: NSBundle) {
		let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
		if appName == "Xcode" {
			if sharedPlugin == nil {
				sharedPlugin = Swimat(bundle: bundle)
				swizzle()
			}
		}
	}

	class func swizzle() {
		method_exchangeImplementations(class_getInstanceMethod(NSDocument.self, #selector(NSDocument.saveDocument)), class_getInstanceMethod(NSDocument.self, #selector(NSDocument.mySaveDocument)))
	}

}
