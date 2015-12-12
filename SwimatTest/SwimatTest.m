#import <XCTest/XCTest.h>
#import "Swimat.h"

@interface SwimatTest : XCTestCase
@property (nonatomic) Swimat *parser;
@end

@implementation SwimatTest

- (void)setUp {
    [super setUp];
	self.parser = [[Swimat alloc]init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFindDiffRange {
	NSRange range;
	range = [self.parser findDiffRange:@"abc d" string2:@"abed"];
	XCTAssert(range.location == 2);
	XCTAssert(range.length == 1);
	
	range = [self.parser findDiffRange:@"abcd" string2:@"abcd"];
	XCTAssert(range.location == 3);
	XCTAssert(range.length == 0);
	
	range = [self.parser findDiffRange:@"abcd " string2:@"abcd"];
	XCTAssert(range.location == 3);
	XCTAssert(range.length == 0);
	
}


@end
