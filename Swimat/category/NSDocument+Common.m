#import "NSDocument+Common.h"
#import "Prefs.h"
#import "Swimat.h"
#import "DTXcodeHeaders.h"
#import "DTXcodeUtils.h"
#import <objc/runtime.h>

@implementation NSDocument(Common)

- (void)externSaveDocumentWithDelegate:(nullable id)delegate didSaveSelector:(nullable SEL)didSaveSelector contextInfo:(nullable void *)contextInfo {
	
	if ([Prefs isAutoFormat]) {
		NSString *ext = [DTXcodeUtils currentSourceCodeDocument].fileURL.pathExtension;
		NSArray *acceptFormat = @[@"swift", @"playground"];
		if ([acceptFormat containsObject:ext]) {
			[[[Swimat alloc] init] format];
		}
	}
	[self externSaveDocumentWithDelegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
}


+ (void)load {
	Method original, swizzle;
	original = class_getInstanceMethod(self, NSSelectorFromString(@"saveDocumentWithDelegate:didSaveSelector:contextInfo:"));
	swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"externSaveDocumentWithDelegate:didSaveSelector:contextInfo:"));
	
	method_exchangeImplementations(original, swizzle);
}

@end
