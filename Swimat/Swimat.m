#import "Swimat.h"
#import "DTXcodeHeaders.h"
#import "DTXcodeUtils.h"
#import "SwiftParser.h"
#import "Prefs.h"

@interface Swimat()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation Swimat

+ (instancetype)sharedPlugin {
	return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
	if (self = [super init]) {
		self.bundle = plugin;
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(didApplicationFinishLaunchingNotification:)
		 name:NSApplicationDidFinishLaunchingNotification
		 object:nil];
	}
	return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
	
	NSMenuItem *editItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
	if (editItem) {
		[[editItem submenu] addItem:[NSMenuItem separatorItem]];
		
		NSMenu *swimatMenu = [[NSMenu alloc] initWithTitle:@"Swimat"];
		NSMenuItem *swimatItem = [[NSMenuItem alloc] initWithTitle:@"Swimat" action:nil keyEquivalent:@""];
		[swimatItem setSubmenu:swimatMenu];
		[[editItem submenu] addItem:swimatItem];
		
		NSMenuItem *formatItem = [[NSMenuItem alloc] initWithTitle:@"Format" action:@selector(formatString) keyEquivalent:@"l"];
		[formatItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSCommandKeyMask | NSAlternateKeyMask];
		[formatItem setTarget:[Swimat class]];
		[swimatMenu addItem:formatItem];
		
		[swimatMenu addItem:[NSMenuItem separatorItem]];
		
		NSString *indent_type = [Prefs getIndent];
		for (NSString *title in [Prefs getIndentArray]) {
			NSMenuItem *indentItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(updateIndent:) keyEquivalent:@""];
			[indentItem setTarget:[Swimat class]];
			if ([indentItem.title isEqualToString:indent_type]) {
				indentItem.state = NSOnState;
			}
			[swimatMenu addItem:indentItem];
		}
		
		[swimatMenu addItem:[NSMenuItem separatorItem]];
		NSMenuItem *autoItem = [[NSMenuItem alloc] initWithTitle:@"Auto Format before Save" action:@selector(updateAutoFormat:) keyEquivalent:@""];
		[autoItem setTarget:[Swimat class]];
		if ([Prefs isAutoFormat]) {
			autoItem.state = NSOnState;
		} else {
			autoItem.state = NSOffState;
		}
		[swimatMenu addItem:autoItem];
	}
}

+ (void)updateAutoFormat:(NSMenuItem *)menuItem {
	bool autoFormat = ![Prefs isAutoFormat];
	[Prefs setAutoFormat:autoFormat];
	if (autoFormat) {
		menuItem.state = NSOnState;
	} else {
		menuItem.state = NSOffState;
	}
}

+ (void)updateIndent:(NSMenuItem *)menuItem {
	[Prefs setIndent:menuItem.title];
	for (NSMenuItem *item in menuItem.parentItem.submenu.itemArray) {
		if (item.action == @selector(updateIndent:)) {
			item.state = NSOffState;
		}
	}
	menuItem.state = NSOnState;
}

+ (void)formatString {
	NSDate *methodStart = [NSDate date];
	NSString *ext = [DTXcodeUtils currentSourceCodeDocument].fileURL.pathExtension;
	NSArray *acceptFormat = @[@"swift", @"playground"];
	if ([acceptFormat containsObject:ext]) {
		DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
		NSRange range = [[[sourceTextView selectedRanges] objectAtIndex:0] rangeValue];
		SwiftParser *parser = [[SwiftParser alloc] init];
		NSString *string = [parser formatString: sourceTextView.textStorage.string withRange:range];
		NSArray *array = [NSArray arrayWithObjects:string, [NSValue valueWithRange:[parser getRange]], nil];
		[self setText:array];
	} else {
		NSAlert *alert = [[NSAlert alloc] init];
		[alert setMessageText: @"Only support swift now"];
		[alert runModal];
	}
	NSDate *methodFinish = [NSDate date];
	NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
	NSLog(@"total executionTime = %f", executionTime);
}

+ (void)setUndo {
	NSUndoManager *undoManager = [DTXcodeUtils currentSourceCodeDocument].undoManager;
	DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
	NSString * oldString =	[NSString stringWithString:sourceTextView.textStorage.string];
	NSRange oldRange = [[[sourceTextView selectedRanges] objectAtIndex:0] rangeValue];
	NSArray *oldArray = [NSArray arrayWithObjects:oldString, [NSValue valueWithRange:oldRange], nil];
	[undoManager setActionName:@"Swimat"];
	[undoManager registerUndoWithTarget:self selector:@selector(setText:) object:oldArray];
}

+ (void)setText: (NSArray*) array {
	[self setUndo];
	NSString *string = [array objectAtIndex:0];
	NSRange range = [[array objectAtIndex:1] rangeValue];
	
	DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
	NSRect r = [sourceTextView visibleRect];
	NSString *orString = sourceTextView.string;
	
	NSRange diff = [self findDiffRange:string string2:orString];
	NSUInteger start = diff.location;
	NSUInteger end = diff.length;
	
	[sourceTextView replaceCharactersInRange: NSMakeRange(start, orString.length - end - start) withString:[string substringWithRange:NSMakeRange(start, string.length - end - start)]];
	
	[sourceTextView setSelectedRange:range];
	[sourceTextView scrollRectToVisible:r];
}

+ (NSRange) findDiffRange:(NSString *) string1 string2:(NSString *) string2 {
	NSDate *methodStart = [NSDate date];
	NSUInteger start = 0, end = 1;
	NSUInteger minLen = MIN(string1.length, string2.length);
	if (minLen == 0) {
		return NSMakeRange(0, 0);
	}
	while ([string1 characterAtIndex:start] == [string2 characterAtIndex:start]) {
		if (start < minLen - 1) {
			start++;
		} else {
			break;
		}
	}
	while ([string1 characterAtIndex:string1.length - end] == [string2 characterAtIndex:string2.length - end]) {
		if (minLen - end > start) {
			end++;
		} else {
			break;
		}
	}
	end--;
	NSDate *methodFinish = [NSDate date];
	NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
	NSLog(@"diff executionTime = %f", executionTime);
	return NSMakeRange(start, end);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
