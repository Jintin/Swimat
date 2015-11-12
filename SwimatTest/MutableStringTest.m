#import <XCTest/XCTest.h>
#import "NSMutableString+Common.h"

@interface MutableStringTest : XCTestCase

@end

@implementation MutableStringTest

- (void)testTrimWith {
	NSMutableString *string = [NSMutableString stringWithString:@"abc"];
	[string spaceWith:@"cd"];
	XCTAssertTrue([string isEqualToString:@"abc cd "]);
	string = [NSMutableString stringWithString:@"abc "];
	[string spaceWith:@"cd"];
	XCTAssertTrue([string isEqualToString:@"abc cd "]);
}

- (void) testTrim {
	NSMutableString *string = [NSMutableString stringWithString:@" abc  "];
	[string trim];
	XCTAssertTrue([string isEqualToString:@" abc"]);
	string = [NSMutableString stringWithString:@" abc"];
	[string trim];
	XCTAssertTrue([string isEqualToString:@" abc"]);
}

@end

