import Cocoa

class SwimatViewController: NSViewController {

    let installPath = "/usr/local/bin/"

    @IBOutlet weak var versionLabel: NSTextField! {
        didSet {
            guard let infoDictionary = Bundle.main.infoDictionary,
                let version = infoDictionary["CFBundleShortVersionString"],
                let build = infoDictionary[kCFBundleVersionKey as String] else {
                    return
            }
            versionLabel.stringValue = "Version \(version) (\(build))"
        }
    }

    @IBOutlet weak var installButton: NSButton! {
        didSet {
            refreshInstallButton()
        }
    }

    @IBOutlet weak var paraAlign: NSButton!

    @IBOutlet weak var autoRemoveChar: NSButton!

    @IBOutlet weak var source: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        paraAlign.state = Preferences.areParametersAligned ? 1 : 0
        autoRemoveChar.state = Preferences.areSemicolonsRemoved ? 1 : 0
        formatSource()
    }

    override func viewDidAppear() {
        guard let window = view.window else {
            return
        }
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
    }

    @IBAction func paraAlignClick(_ sender: NSButton) {
        Preferences.areParametersAligned = sender.state == NSOnState
        formatSource()
    }

    @IBAction func autoRemoveChar(_ sender: NSButton) {
        Preferences.areSemicolonsRemoved = sender.state == NSOnState
    }
    func formatSource() {
        Indent.char = "    "
        Indent.size = 4
        Indent.paraAlign = Preferences.areParametersAligned
        let parser = SwiftParser(string: source.stringValue)
        do {
            let newValue = try parser.format()
            source.stringValue = newValue
        } catch {

        }
    }

    @IBAction func install(_ sender: Any) {
        // Migrate this to SMJobBless?
        let path = Bundle.main.bundleURL
            .appendingPathComponent("Contents", isDirectory: true)
            .appendingPathComponent("Helpers", isDirectory: true)
            .appendingPathComponent("swimat")
            .path
        var error: NSDictionary?
        let script = NSAppleScript(source: "do shell script \"ln -s \'\(path)\' \(installPath)swimat\" with administrator privileges")
        script?.executeAndReturnError(&error)
        if error != nil {
            let alert = NSAlert()
            alert.messageText = "There was an error symlinking swimat."
            alert.informativeText = "You can try manually linking swimat by running:\n\nln -s /Applications/Swimat.app/Contents/Helpers/swimat \(installPath)swimat"
            alert.alertStyle = .warning
            alert.runModal()
        }
        refreshInstallButton()
    }

    func refreshInstallButton() {
        // Check for swimat, fileExists(atPath:) returns false for symlinks
        if (try? FileManager.default.attributesOfItem(atPath: "\(installPath)swimat")) != nil {
            installButton.title = "swimat installed to \(installPath)"
            installButton.isEnabled = false
        } else {
            installButton.title = "Install swimat to \(installPath)"
            installButton.isEnabled = true
        }
    }
}
