import AppKit
import Foundation
import Cocoa

var sharedPlugin: Swimat?

class Swimat: NSObject {
	var bundle: NSBundle
	lazy var center = NSNotificationCenter.defaultCenter()

	init(bundle: NSBundle) {
		self.bundle = bundle

		super.init()
		center.addObserver(self, selector: #selector(Swimat.createMenuItems), name: NSApplicationDidFinishLaunchingNotification, object: nil)
	}

	deinit {
		removeObserver()
	}

	func removeObserver() {
		center.removeObserver(self)
	}

	func createMenuItems() {
		removeObserver()
		let item = NSApp.mainMenu!.itemWithTitle("Edit")
		if item != nil {
			let actionMenuItem = NSMenuItem(title: "Swimat2", action: #selector(Swimat.doMenuAction), keyEquivalent: "l")

			actionMenuItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.AlphaShiftKeyMask.rawValue | NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue)
			actionMenuItem.target = self
			item!.submenu!.addItem(NSMenuItem.separatorItem())
			item!.submenu!.addItem(actionMenuItem)
		}
	}

	func doMenuAction() {
		let sourceTextView: DVTSourceTextView = DTXcodeUtils.currentSourceTextView()
		let string = sourceTextView.textStorage!.string
		let range = sourceTextView.selectedRanges[0].rangeValue

		let newString = SwiftParser().format(string, range: range)
		setText(newString, range: range)
	}

	func setUndo() {
//		let undoManager = DTXcodeUtils.currentSourceCodeDocument().undoManager
//		let sourceTextView = DTXcodeUtils.currentSourceTextView()
//		undoManager?.setActionName("Swimat")
//		undoManager?.registerUndoWithTarget(self, selector: #selector(Swimat.setText(_:)), object: sourceTextView)
	}

	func setText(string: String, range: NSRange) {
		setUndo()
//		let string = sourceTextView.textStorage!.string
//		let range = sourceTextView.selectedRanges[0].rangeValue

		let source = DTXcodeUtils.currentSourceTextView()
		let rect = source.visibleRect
		let oldString = source.textStorage!.string

		let diff = string.findDiff(oldString)
		print(diff)
		source.replaceCharactersInRange(NSMakeRange(diff.start, oldString.count - diff.end - diff.start), withString: string[diff.start ..< string.count - diff.end])

		source.setSelectedRange(range)
		source.scrollRectToVisible(rect)
	}
}
