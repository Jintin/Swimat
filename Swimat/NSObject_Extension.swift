import Foundation

extension NSObject {

	class func pluginDidLoad(bundle: NSBundle) {
		let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? NSString
		if appName == "Xcode" {
			if sharedPlugin == nil {
				sharedPlugin = Swimat(bundle: bundle)
			}
		}
	}

}
