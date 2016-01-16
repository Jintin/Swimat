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
			[Swimat formatString];
		}
	}
	[self externSaveDocumentWithDelegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
}

- (void)externSaveToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation completionHandler:(void (^)(NSError * __nullable errorOrNil))completionHandler NS_AVAILABLE_MAC(10_7) {
	if ([Prefs isFormatOnBuild]) {
		NSString *ext = [DTXcodeUtils currentSourceCodeDocument].fileURL.pathExtension;
		NSArray *acceptFormat = @[@"swift"];
		if ([acceptFormat containsObject:ext]) {
			[Swimat formatString];
		}
	}
	[self externSaveToURL:url ofType:typeName forSaveOperation:saveOperation completionHandler:completionHandler];
}

+ (void)load {
	Method original, swizzle;
	original = class_getInstanceMethod(self, NSSelectorFromString(@"saveDocumentWithDelegate:didSaveSelector:contextInfo:"));
	swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"externSaveDocumentWithDelegate:didSaveSelector:contextInfo:"));
	
	method_exchangeImplementations(original, swizzle);
	
	original = class_getInstanceMethod(self, NSSelectorFromString(@"saveToURL:ofType:forSaveOperation:completionHandler:"));
	swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"externSaveToURL:ofType:forSaveOperation:completionHandler:"));
	
	method_exchangeImplementations(original, swizzle);
}

@end
