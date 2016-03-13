import AppKit

var sharedPlugin: Swimat?

class Swimat: NSObject {

	var bundle: NSBundle
	lazy var center = NSNotificationCenter.defaultCenter()

	init(bundle: NSBundle) {
		self.bundle = bundle

		super.init()
		center.addObserver(self, selector: Selector("createMenuItems"), name: NSApplicationDidFinishLaunchingNotification, object: nil)
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
			let actionMenuItem = NSMenuItem(title: "Do Action", action: "doMenuAction", keyEquivalent: "")
			actionMenuItem.target = self
			item!.submenu!.addItem(NSMenuItem.separatorItem())
			item!.submenu!.addItem(actionMenuItem)
		}
	}

	func doMenuAction() {
		let error = NSError(domain: "Hello World!", code: 42, userInfo: nil)
		NSAlert(error: error).runModal()
		let sourceTextView: DVTSourceTextView = DTXcodeUtils.currentSourceTextView()
		let range = sourceTextView.selectedRanges[0].rangeValue
		print(range)
//		DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
//		NSRange range = [[[sourceTextView selectedRanges] objectAtIndex:0] rangeValue];
//		SwiftParser *parser = [[SwiftParser alloc] init];
//
	}

	func setUndo() {
		let undoManager = DTXcodeUtils.currentSourceCodeDocument().undoManager
		let sourceTextView = DTXcodeUtils.currentSourceTextView()
		undoManager?.setActionName("Swimat")
		undoManager?.registerUndoWithTarget(self, selector: "setText:", object: sourceTextView)
	}

	func setText(sourceTextView: DVTSourceTextView) {
		setUndo()
//		let string = sourceTextView.textStorage?.string
//		let range = sourceTextView.selectedRanges[0].rangeValue
	}

//	+ (void)setText: (NSArray*) array {
//	[self setUndo];
//	NSString *string = [array objectAtIndex:0];
//	NSRange range = [[array objectAtIndex:1] rangeValue];
//
//	DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
//	NSRect r = [sourceTextView visibleRect];
//	NSString *orString = sourceTextView.string;
//
//	NSRange diff = [self findDiffRange:string string2:orString];
//	NSUInteger start = diff.location;
//	NSUInteger end = diff.length;
//
//	[sourceTextView replaceCharactersInRange: NSMakeRange(start, orString.length - end - start) withString:[string substringWithRange:NSMakeRange(start, string.length - end - start)]];
//
//	[sourceTextView setSelectedRange:range];
//	[sourceTextView scrollRectToVisible:r];
//	}
}
