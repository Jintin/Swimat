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

- (void) testAZ {
	XCTAssertFalse([Parser isAZ:' ']);
	XCTAssertTrue([Parser isAZ:'1']);
	XCTAssertTrue([Parser isAZ:'0']);
	XCTAssertTrue([Parser isAZ:'a']);
	XCTAssertTrue([Parser isAZ:'z']);
	XCTAssertTrue([Parser isAZ:'A']);
	XCTAssertTrue([Parser isAZ:'Z']);
}

@end