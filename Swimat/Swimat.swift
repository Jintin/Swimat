import AppKit
import Foundation
import Cocoa

var sharedPlugin: Swimat?

class Swimat: NSObject {
	let name = "Swimat2"

	var bundle: NSBundle
	lazy var center = NSNotificationCenter.defaultCenter()

	init(bundle: NSBundle) {
		self.bundle = bundle

		super.init()
		center.addObserver(self, selector: #selector(createMenuItems), name: NSApplicationDidFinishLaunchingNotification, object: nil)
	}

	deinit {
		removeObserver()
	}

	func removeObserver() {
		center.removeObserver(self)
	}

	func createMenuItems() {
		removeObserver()
		if let item = NSApp.mainMenu!.itemWithTitle("Edit") {
			let swimatItem = NSMenuItem(title: name, action: #selector(swimatAction), keyEquivalent: "l")

			swimatItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.AlphaShiftKeyMask.rawValue | NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue)
			swimatItem.target = self

			item.submenu!.addItem(.separatorItem())
			item.submenu!.addItem(swimatItem)
		}
	}

	func swimatAction() {
		let methodStart = NSDate()

		let source = DTXcodeUtils.currentSourceTextView()
		let string = source.textStorage!.string
		let range = source.selectedRanges[0].rangeValue
		let result = SwiftParser(string: string, range: range).format()
		setText(result.string, range: result.range!)

		let executionTime = NSDate().timeIntervalSinceDate(methodStart)
		print("total   executionTime = \(executionTime)");
	}

	func setText(string: String, range: NSRange) {
		let methodStart = NSDate()

		let source = DTXcodeUtils.currentSourceTextView()
		let oldString = source.textStorage!.string

		if let diff = string.findDiff(oldString) {
			let oldRange = source.selectedRanges[0].rangeValue
			if let undoManager = DTXcodeUtils.currentSourceCodeDocument().undoManager {
				undoManager.registerUndoWithTarget(self) {
					Swimat -> Void in

					self.setText(oldString, range: oldRange)
				}
				undoManager.setActionName(name)
			}
			source.replaceCharactersInRange(oldString.nsRangeFromRange(diff.range2)!, withString: string[diff.range1])
			source.setSelectedRange(range)
		}

		let executionTime = NSDate().timeIntervalSinceDate(methodStart)
		print("setText executionTime = \(executionTime)");
	}
}
