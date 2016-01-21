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

- (void) reset {
	self.parser->retString = [NSMutableString string];
	self.parser->orString = @"";
	self.parser->strIndex = 0;
	self.parser->indent = 0;
	self.parser->onetimeIndent = 0;
}

- (void) testAppendString {
	[self reset];
	[self.parser appendString:@"abc"];
	XCTAssertEqual(self.parser->strIndex, 3);
	XCTAssert([self.parser->retString isEqualToString:@"abc"]);
	[self reset];
	[self.parser appendString:@" abc "];
	XCTAssertEqual(self.parser->strIndex, 3);
	XCTAssert([self.parser->retString isEqualToString:@" abc "]);
 }

- (void) testAppendChar {
	[self reset];
	[self.parser appendChar:'a'];
	XCTAssertEqual(self.parser->strIndex, 1);
	XCTAssert([self.parser->retString isEqualToString:@"a"]);
}

- (void) testSpaceWith {
	[self reset];
	[self.parser spaceWith:@"abc"];
	XCTAssertEqual(self.parser->strIndex, 3);
	XCTAssert([self.parser->retString isEqualToString:@"abc "]);
	
	[self reset];
	[self.parser appendChar:'a'];
	[self.parser spaceWith:@"abc"];
	XCTAssertEqual(self.parser->strIndex, 4);
	XCTAssert([self.parser->retString isEqualToString:@"a abc "]);
}

- (void) testSpaceWithArray {
	[self reset];
	NSArray *array = @[@"aa", @"bb"];
	self.parser->orString = @"aa";
	[self.parser spaceWithArray:array];
	NSLog(@"'%@'", self.parser->retString);
	XCTAssertEqual(self.parser->strIndex, 2);
	XCTAssert([self.parser->retString isEqualToString:@"aa "]);
	
	[self reset];
	self.parser->orString = @"a cc";
	self.parser->strIndex = 2;
	[self.parser spaceWithArray:array];
	NSLog(@"'%@'", self.parser->retString);
	XCTAssertEqual(self.parser->strIndex, 2);
	XCTAssert([self.parser->retString isEqualToString:@""]);
}

//-(void) trimWithIndent;
//
//-(void) addIndent:(NSMutableString *)editString withCount:(int) count;
//
//-(bool) isNext:(unichar) check;
//
//-(bool) isNextString:(NSString *) check;
//
//-(NSUInteger) addToEnd:(NSString *) string edit:(NSMutableString *) editString withIndex:(NSUInteger) index;

@end