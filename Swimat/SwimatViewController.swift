import Cocoa

class SwimatViewController: NSViewController {

    let installPath = "/usr/local/bin/"

    @IBOutlet weak var swimatTabView: NSTabView!

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
    @IBOutlet weak var installationLabel: NSTextField! {
        didSet {
            guard let url = Bundle.main.url(forResource: "Installation", withExtension: "html"),
                let string = try? NSMutableAttributedString(url: url, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
                    return
            }
            string.addAttributes([.foregroundColor: NSColor.textColor], range: NSRange(location: 0, length: string.length))
            installationLabel.attributedStringValue = string
        }
    }
    @IBOutlet weak var installButton: NSButton! {
        didSet {
            refreshInstallButton()
        }
    }

    @IBOutlet weak var parameterAlignmentCheckbox: NSButton! {
        didSet {
            parameterAlignmentCheckbox.state = Preferences.areParametersAligned ? .on : .off
        }
    }
    @IBOutlet weak var removeSemicolonsCheckbox: NSButton! {
        didSet {
            removeSemicolonsCheckbox.state = Preferences.areSemicolonsRemoved ? .on : .off
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func viewDidAppear() {
        guard let window = view.window else {
            return
        }
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
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

    @IBAction func updateParameterAlignment(_ sender: NSButton) {
        Preferences.areParametersAligned = sender.state == .on
        preferencesChanged()
    }

    @IBAction func updateRemoveSemicolons(_ sender: NSButton) {
        Preferences.areSemicolonsRemoved = sender.state == .on
        preferencesChanged()
    }

    func preferencesChanged() {
        let notification = Notification(name: Notification.Name("SwimatPreferencesChangedNotification"))
        NotificationCenter.default.post(notification)
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
