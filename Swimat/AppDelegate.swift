import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {

    }

    func applicationWillTerminate(_ aNotification: Notification) {

    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func openPreferences(_ sender: Any) {
        (NSApplication.shared.mainWindow?.contentViewController as? SwimatViewController)?.swimatTabView.selectTabViewItem(withIdentifier: "options")
    }

}
