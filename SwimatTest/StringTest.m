#import <XCTest/XCTest.h>
#import "NSString+Common.h"

@interface StringTest : XCTestCase

@end

@implementation StringTest

- (void) testStartWith {
	NSString *string = @"abc";
	XCTAssertTrue([string isStartWith:@"bc" fromIndex:1]);
	string = @"acc";
	XCTAssertFalse([string isStartWith:@"bc" fromIndex:1]);
}

- (void) testNextIndexSearch {
	NSString *string = @"abcaa";
	XCTAssertEqual([string nextIndex:1 search:@"aa" defaults:-1], 5);
}

- (void) testCompleteLine {
	NSString *string = @"a = b + c\n";
	XCTAssertTrue([string isCompleteLine:string.length - 1]);
	string = @"a = \n";
	XCTAssertFalse([string isCompleteLine:string.length - 1]);
	string = @"a = b + \n";
	XCTAssertFalse([string isCompleteLine:string.length - 1]);
	string = @"a = b++ \n";
	XCTAssertTrue([string isCompleteLine:string.length - 1]);
	string = @"a = b\n  ++b";
	XCTAssertTrue([string isCompleteLine:5]);
}

- (void) testNextIndex {
	XCTAssertTrue(3 == [@"abcde" nextIndex:0 defaults:-1 compare:^bool(NSString *next, NSUInteger curIndex){
		return [next isEqualToString:@"d"];
	}]);
}

- (void) testNextQuote {
	XCTAssertTrue(4 == [@"\"abc\"" nextQuoteIndex:1]);
}

- (void) testNextSpace {
	XCTAssertTrue(3 == [@"abc e" nextSpaceIndex:1 defaults:-1]);
}

- (void) testNextNonSpace {
	XCTAssertTrue(3 == [@"   d " nextNonSpaceIndex:0 defaults:-1]);
}

- (void) testLastIndex {
	XCTAssertTrue(3 == [@"abcde" lastIndex:4 defaults:-1 compare:^bool(NSString *next, NSUInteger curIndex){
		return [next isEqualToString:@"d"];
	}]);
}

- (void) testLastSpace {
	XCTAssertTrue(0 == [@" bcde" lastSpaceIndex:4 defaults:-1]);
}

- (void) testLastNonSpace {
	XCTAssertTrue(1 == [@" b   " lastNonSpaceIndex:4 defaults:-1]);
}

- (void) testLastChar {
	XCTAssertTrue([@"abcd " lastCharIndex:4 defaults:-1] == 3);
	XCTAssertTrue([@"ab   " lastCharIndex:4 defaults:-1] == 1);
}

- (void) testLastWord {
	NSString *string = [@"a bcd " lastWord:3];
	XCTAssertTrue([@"bc" isEqualToString:string]);
}

- (void) testNextWord {
	NSString *string = [@"a bc  " nextWord:1];
	NSLog(@"%@",string);
	XCTAssertTrue([@"bc" isEqualToString:string]);
}

@end
