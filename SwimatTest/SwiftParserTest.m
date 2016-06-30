//
//  SwiftParserTest.m
//  Swimat
//
//  Created by Reimar Twelker on 18.03.16.
//  Copyright © 2016 jintin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SwiftParser.h"
#import "Prefs.h"

@interface SwiftParserTest : XCTestCase

@property (nonatomic, strong) SwiftParser *parser;

@end

@implementation SwiftParserTest

- (void)setUp {
    [super setUp];
    
    [Prefs setIndent:INDENT_SPACE4];
    [Prefs setIndentEmptyLine:YES];
    
    self.parser = [[SwiftParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
    [super tearDown];
}

- (void)logInput:(NSString *)inputString output:(NSString *)outputString {
    NSLog(@"\n\n<-- INPUT:\n\n%@\n\n--> OUTPUT:\n\n%@\n\n", [self stringShowingInvisibles:inputString], [self stringShowingInvisibles:outputString]);
}

- (NSString *)stringShowingInvisibles:(NSString *)string {
    NSMutableString *stringShowingInvisibles = [NSMutableString stringWithString:string];
    [stringShowingInvisibles replaceOccurrencesOfString:@" " withString:@"_" options:0 range:NSMakeRange(0, stringShowingInvisibles.length)];
    [stringShowingInvisibles replaceOccurrencesOfString:@"\n" withString:@"\\n\n" options:0 range:NSMakeRange(0, stringShowingInvisibles.length)];
    [stringShowingInvisibles replaceOccurrencesOfString:@"\t" withString:@"\\t\t" options:0 range:NSMakeRange(0, stringShowingInvisibles.length)];
    return [NSString stringWithString:stringShowingInvisibles];
}

#pragma mark - Formatting rule: Break before opening brace

static NSString *const SWMSwiftParserTestNoNewlineSourceString = @"func a(b:Int){\nreturn (b+1)\n}";
static NSString *const SWMSwiftParserTestSingleNewlineSourceString = @"func a(b:Int)\n{\nreturn (b+1)\n}";
static NSString *const SWMSwiftParserTestMultipleNewlineSourceString = @"func a(b:Int)\n\n\n{\nreturn (b+1)\n}";

- (void)enableBreakBeforeOpeningBraceRule:(SWMBreakBeforeOpeningBraceRule)rule {
    [Prefs setBreakBeforeOpeningBraceRule:rule];
}

#pragma mark Ignore

- (void)test_breakBeforeOpeningBraceRuleIgnore_shouldKeepNewline {
    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleIgnore];
    
    NSString *input = SWMSwiftParserTestSingleNewlineSourceString;
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    NSInteger outputCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@")" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssertEqual(outputCount, 1);
}

- (void)test_breakBeforeOpeningBraceRuleIgnore_shouldKeepOneNewline_ifThereAreMultipleNewlines {
    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleIgnore];
    
    NSString *input = SWMSwiftParserTestMultipleNewlineSourceString;
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
 
    NSInteger outputCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@")" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssertEqual(outputCount, 2);
}

- (void)test_breakBeforeOpeningBraceRuleIgnore_shouldDoNothing_ifThereIsNoNewline {
    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleIgnore];
    
    NSString *input = SWMSwiftParserTestNoNewlineSourceString;
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    NSInteger outputCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@")" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssertEqual(outputCount, 0);
}

#pragma mark Remove

- (void)test_breakBeforeOpeningBraceRuleRemove_shouldRemoveNewline {
    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleRemove];
    
    NSString *input = SWMSwiftParserTestSingleNewlineSourceString;
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    NSInteger outputCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@")" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssertEqual(outputCount, 0);
}

- (void)test_breakBeforeOpeningBraceRuleRemove_shouldRemoveAllNewlines {
    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleRemove];
    
    NSString *input = SWMSwiftParserTestMultipleNewlineSourceString;
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    NSInteger outputCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@")" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssertEqual(outputCount, 0);
}

- (void)test_breakBeforeOpeningBraceRuleRemove_shouldDoNothing_ifThereIsNoNewline {
    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleRemove];
    
    NSString *input = SWMSwiftParserTestNoNewlineSourceString;
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    NSInteger outputCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@")" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssertEqual(outputCount, 0);
}

#pragma mark Force

- (void)test_breakBeforeOpeningBraceRuleForce_shouldDoNothing_ifThereIsOneNewline {
    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleForce];
    
    NSString *input = SWMSwiftParserTestSingleNewlineSourceString;
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    NSInteger outputCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@")" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssertEqual(outputCount, 1);
}

- (void)test_breakBeforeOpeningBraceRuleForce_shouldInsertOneNewline_ifThereIsNoNewline {
    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleForce];
    
    NSString *input = SWMSwiftParserTestNoNewlineSourceString;
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    NSInteger outputCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@")" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssertEqual(outputCount, 1);
}

- (void)test_breakBeforeOpeningBraceRuleForce_shouldKeepOneNewline_ifThereAreMultipleNewlines {
    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleForce];
    
    NSString *input = SWMSwiftParserTestMultipleNewlineSourceString;
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    NSInteger outputCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@")" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssertEqual(outputCount, 2);
}

#pragma mark - Newlines

- (void)test_parserShouldRemoveEmptyLineBeforeOpeningBrace {
    NSString *input = @"if a == 1\n\n{\nlet b = a\n}";
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    const NSInteger newlineCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@"a == 1" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssert(newlineCount < 2); // Make sure there is no empty line, if there are one or two newlines depends on the "break before opening brace" rule!
}

// TOOD: only need NewlinesToOne
//- (void)test_parserShouldRemoveEmptyLineBeforeClosingBrace {
//    NSString *input = @"if a == 1 {\nlet b = a\n\n}";
//    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
//    [self logInput:input output:output];
//    
//    const NSInteger newlineCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@"b = a" andFirstOccurrenceOfSubstring:@"}"];
//    XCTAssertEqual(newlineCount, 1);
//}
// TOOD: only need NewlinesToOne
//- (void)test_parserShouldRemoveEmptyLineAfterOpeningBrace {
//    NSString *input = @"if a == 1 {\n\nlet b = a\n}";
//    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
//    [self logInput:input output:output];
//    
//    const NSInteger newlineCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@"{" andFirstOccurrenceOfSubstring:@"b = a"];
//    XCTAssertEqual(newlineCount, 1);
//}

- (void)test_parserShouldReduceConsecutiveNewlinesToOne {
    NSString *input = @"let a = 1\n\n\n\nlet b = a + 1";
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    const NSInteger newlineCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@"= 1" andFirstOccurrenceOfSubstring:@"let b"];
    XCTAssertEqual(newlineCount, 2);
}

#pragma mark - Helpers

- (NSInteger)numberOfNewlinesInString:(NSString *)string betweenFirstOccurrenceOfSubstring:(NSString *)substring1 andFirstOccurrenceOfSubstring:(NSString *)substring2 {
    NSInteger n = 0;
    NSString *substring = [self substringOfString:string betweenFirstOccurrenceOfSubstring:substring1 andFirstOccurrenceOfSubstring:substring2];
    for (int i = 0; i < substring.length; ++i) {
        if ([substring characterAtIndex:i] == '\n') {
            ++n;
        }
    }
    
    return n;
}

- (NSString *)substringOfString:(NSString *)string betweenFirstOccurrenceOfSubstring:(NSString *)substring1 andFirstOccurrenceOfSubstring:(NSString *)substring2 {
    NSRange r1 = [string rangeOfString:substring1];
    NSRange r2 = [string rangeOfString:substring2 options:0 range:NSMakeRange(r1.location, string.length - r1.location)];
    NSRange substringRange = NSMakeRange(r1.location + r1.length, r2.location - (r1.location + r1.length));
    XCTAssert(substringRange.location >= 0 && substringRange.length >= 0);
    return [string substringWithRange:substringRange];
}

@end
