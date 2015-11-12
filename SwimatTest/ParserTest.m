#import <XCTest/XCTest.h>
#import "Parser.h"

@interface ParserTest : XCTestCase
@property (nonatomic) Parser *parser;
@end

@implementation ParserTest

- (void)setUp {
	[super setUp];
	self.parser = [[Parser alloc]init];
}

- (void) testSpace {
	XCTAssertTrue([Parser isSpace:' ']);
	XCTAssertTrue([Parser isSpace:'\t']);
	XCTAssertFalse([Parser isSpace:'a']);
}

- (void) testBlank {
	XCTAssertTrue([Parser isBlank:' ']);
	XCTAssertTrue([Parser isBlank:'\t']);
	XCTAssertTrue([Parser isBlank:'\n']);
	XCTAssertFalse([Parser isBlank:'a']);
}

- (void) testQuote {
	XCTAssertTrue([Parser isQuote:'"']);
	XCTAssertFalse([Parser isQuote:'\'']);
}

- (void) testUpperBrackets {
	XCTAssertTrue([Parser isUpperBrackets:'[']);
	XCTAssertTrue([Parser isUpperBrackets:'(']);
	XCTAssertTrue([Parser isUpperBrackets:'{']);
	XCTAssertFalse([Parser isUpperBrackets:'|']);
}

- (void) testLowerBrackets {
	XCTAssertTrue([Parser isLowerBrackets:']']);
	XCTAssertTrue([Parser isLowerBrackets:')']);
	XCTAssertTrue([Parser isLowerBrackets:'}']);
	XCTAssertFalse([Parser isLowerBrackets:'|']);
}

- (void) testAddStringToNext {
	NSMutableString *string = [NSMutableString string];
	int index = (int)[self.parser addStringToNext:@"\n" withOffset:1 edit:string withString:@"abcd\nefg"];
	
	XCTAssertTrue([string isEqualToString:@"bcd\n"]);
	XCTAssertTrue(index == 5);
	string = [NSMutableString string];
	index = (int)[self.parser addStringToNext:@"\n" withOffset:1 edit:string withString:@"abcd"];
	
	XCTAssertTrue([string isEqualToString:@"bcd"]);
	XCTAssertTrue(index == 4);
	
}

@end