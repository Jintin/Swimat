//
//  SwimatViewController.swift
//  Swimat
//
//  Created by Saagar Jha on 1/8/17.
//  Copyright © 2017 jintin. All rights reserved.
//

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
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        guard let window = view.window else {
            return
        }
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true;
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
        if ((try? FileManager.default.attributesOfItem(atPath: "\(installPath)swimat")) != nil) {
            installButton.title = "swimat installed to \(installPath)"
            installButton.isEnabled = false
        } else {
            installButton.title = "Install swimat to \(installPath)"
            installButton.isEnabled = true
        }
    }
}
