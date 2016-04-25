import AppKit
import Foundation
import Cocoa

var sharedPlugin: Swimat?

class Swimat: NSObject {

	let name = "Swimat"
	let SaveTrigger = "Format when Save"

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
		guard let editItem = NSApp.mainMenu!.itemWithTitle("Edit") else {
			return
		}
		let swimatMenu = NSMenu.init(title: name)
		let swimatItem = NSMenuItem.init(title: name, action: nil, keyEquivalent: "")
		swimatItem.submenu = swimatMenu
		editItem.submenu!.addItem(.separatorItem())
		editItem.submenu!.addItem(swimatItem)

		let formatItem = NSMenuItem(title: "Format", action: #selector(Swimat.formatAction), keyEquivalent: "l")

		formatItem.keyEquivalentModifierMask = Int(NSEventModifierFlags.AlphaShiftKeyMask.rawValue | NSEventModifierFlags.CommandKeyMask.rawValue | NSEventModifierFlags.AlternateKeyMask.rawValue)
		formatItem.target = self
		swimatMenu.addItem(formatItem)

		swimatMenu.addItem(.separatorItem())

		let indentType = Prefs.getIndent()
		for title in Prefs.IndentTitle {
			let item = NSMenuItem(title: title, action: #selector(indentAction), keyEquivalent: "")
			if Prefs.IndentTable[title]! == indentType {
				item.state = NSOnState
			}
			item.target = self
			swimatMenu.addItem(item)
		}

		swimatMenu.addItem(.separatorItem())
		let saveItem = NSMenuItem(title: SaveTrigger, action: #selector(updateBool), keyEquivalent: "")
		saveItem.target = self
		saveItem.state = Prefs.isSaveTrigger() ? NSOnState : NSOffState
		swimatMenu.addItem(saveItem)
	}

	func updateBool(menuItem: NSMenuItem) {
		let state = menuItem.state != NSOnState
		switch menuItem.title {
		case SaveTrigger:
			Prefs.saveTrigger(state)
			break
		default:
			break
		}
		menuItem.state = state ? NSOnState : NSOffState
	}

	func indentAction(menuItem: NSMenuItem) {
		Prefs.setIndent(Prefs.IndentTable[menuItem.title]!)
		for item in menuItem.parentItem!.submenu!.itemArray {
			if item.action == #selector(indentAction) {
				item.state = NSOffState
			}
		}
		menuItem.state = NSOnState
	}

	func formatAction() {
		#if DEBUG
			let methodStart = NSDate()
		#endif
		if let ext = DTXcodeUtils.currentSourceCodeDocument()?.fileURL?.pathExtension {
			let acceptList = ["swift", "playground"]
			if acceptList.contains(ext) {
				let source = DTXcodeUtils.currentSourceTextView()
				let string = source.textStorage!.string
				let range = source.selectedRanges[0].rangeValue
				let result = SwiftParser(string: string, range: range).format()
				setText(result.string, range: result.range!)
			}
		}
		#if DEBUG
			let executionTime = NSDate().timeIntervalSinceDate(methodStart)
			print("\(#function) executionTime = \(executionTime)")
		#endif
	}

	func setText(string: String, range: NSRange) {
		#if DEBUG
			let methodStart = NSDate()
		#endif
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

			let selRange = oldString.nsRangeFromRange(diff.range2)!

			let diffString = string[diff.range1]
			source.replaceCharactersInRange(selRange, withString: diffString)
			source.setSelectedRange(range)
		}
		#if DEBUG
			let executionTime = NSDate().timeIntervalSinceDate(methodStart)
			print("\(#function)  executionTime = \(executionTime)")
		#endif
	}

}
