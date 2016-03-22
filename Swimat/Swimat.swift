import AppKit

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
			let actionMenuItem = NSMenuItem(title: "Do Action", action: #selector(Swimat.doMenuAction), keyEquivalent: "")
			actionMenuItem.target = self
			item!.submenu!.addItem(NSMenuItem.separatorItem())
			item!.submenu!.addItem(actionMenuItem)
		}
	}

	func doMenuAction() {
		let sourceTextView: DVTSourceTextView = DTXcodeUtils.currentSourceTextView()
		let string = sourceTextView.textStorage!.string
		let range = sourceTextView.selectedRanges[0].rangeValue

		SwiftParser().format(string, range: range)
	}

	func setUndo() {
		let undoManager = DTXcodeUtils.currentSourceCodeDocument().undoManager
		let sourceTextView = DTXcodeUtils.currentSourceTextView()
		undoManager?.setActionName("Swimat")
		undoManager?.registerUndoWithTarget(self, selector: #selector(Swimat.setText(_:)), object: sourceTextView)
	}

	func setText(sourceTextView: DVTSourceTextView) {
		setUndo()
		let string = sourceTextView.textStorage!.string
		let range = sourceTextView.selectedRanges[0].rangeValue

		let source = DTXcodeUtils.currentSourceTextView()
		let rect = sourceTextView.visibleRect
		let oldString = source.textStorage!.string

		let diff = string.findDiff(oldString)
		sourceTextView.replaceCharactersInRange(NSMakeRange(diff.start, oldString.count - diff.end - diff.start), withString: string)

		sourceTextView.setSelectedRange(range)
		sourceTextView.scrollRectToVisible(rect)
	}
}
