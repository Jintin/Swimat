#import "Swimat.h"
#import "DTXcodeHeaders.h"
#import "DTXcodeUtils.h"
#import "SwiftParser.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
	
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Swimat" action:@selector(doMenuAction) keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
    }
}

- (void)doMenuAction {
	NSString *ext = [DTXcodeUtils currentSourceCodeDocument].fileURL.pathExtension;
	
	if ([ext isEqualToString:@"swift"]) {
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
}

- (void)setUndo {
	NSUndoManager *undoManager = [DTXcodeUtils currentSourceCodeDocument].undoManager;
	DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
	NSString * oldString =	[NSString stringWithString:sourceTextView.textStorage.string];
	NSRange oldRange = [[[sourceTextView selectedRanges] objectAtIndex:0] rangeValue];
	NSArray *oldArray = [NSArray arrayWithObjects:oldString, [NSValue valueWithRange:oldRange], nil];
	[undoManager setActionName:@"Swifmat"];
	[undoManager registerUndoWithTarget:self selector:@selector(setText:) object: oldArray];
}

- (void)setText: (NSArray*) array {
	[self setUndo];
	NSString *string = [array objectAtIndex:0];
	NSRange range = [[array objectAtIndex:1] rangeValue];
	
	DVTSourceTextView *sourceTextView = [DTXcodeUtils currentSourceTextView];
	NSRect r = [sourceTextView visibleRect];
	
	[sourceTextView replaceCharactersInRange: NSMakeRange(0, sourceTextView.textStorage.string.length) withString:string];
	[sourceTextView setSelectedRange:range];
	[sourceTextView scrollRectToVisible: r];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
