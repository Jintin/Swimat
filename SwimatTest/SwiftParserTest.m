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
    self.parser = [[SwiftParser alloc] init];
}

- (void)tearDown {
    self.parser = nil;
    [super tearDown];
}

- (void)logSourceCodeString:(NSString *)string label:(NSString *)label {
    NSString *labelWithDelimiter = (label != nil ? [NSString stringWithFormat:@"\n\n%@:\n", label] : @"\n");
    NSLog(@"%@%@\n\n", labelWithDelimiter, string);
}

- (void)logInput:(NSString *)string {
    [self logSourceCodeString:string label:@"Input"];
}

- (void)logOutput:(NSString *)string {
    [self logSourceCodeString:string label:@"Output"];
}

- (void)logInput:(NSString *)inputString output:(NSString *)outputString {
    [self logInput:inputString];
    [self logOutput:outputString];
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
    XCTAssertEqual(outputCount, 1);
}

- (void)test_breakBeforeOpeningBraceRuleIgnore_shouldDoNothing_ifThereIsNoNewline {
    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleIgnore];
    
    NSString *input = SWMSwiftParserTestNoNewlineSourceString;
    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
    [self logInput:input output:output];
    
    NSInteger outputCount = [self numberOfNewlinesInString:output betweenFirstOccurrenceOfSubstring:@")" andFirstOccurrenceOfSubstring:@"{"];
    XCTAssertEqual(outputCount, 0);
}

//- (void)test_breakBeforeOpeningBraceRuleIgnore {
//    [Prefs setIndentEmptyLine:YES];
//    [Prefs setIndent:INDENT_SPACE4];
//    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleIgnore];
//    
//    NSString *input = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace"];
//    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
//    
//    NSString *expected = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace_ignore"];
//    XCTAssert([output isEqualToString:expected]);
//}

//- (void)test_breakBeforeOpeningBraceRuleIgnore_noIndentationOfEmptyLines {
//    [Prefs setIndentEmptyLine:NO];
//    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleIgnore];
//    
//    NSString *input = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace"];
//    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
//    
//    NSString *expected = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace_ignore_noindent"];
//    XCTAssert([output isEqualToString:expected]);
//}

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

//- (void)test_breakBeforeOpeningBraceRuleRemove {
//    [Prefs setIndentEmptyLine:YES];
//    [Prefs setIndent:INDENT_SPACE4];
//    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleRemove];
//    
//    NSString *input = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace"];
//    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
//    
//    NSString *expected = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace_remove"];
//    XCTAssert([output isEqualToString:expected]);
//}

//- (void)test_breakBeforeOpeningBraceRuleRemove_noIndentationOfEmptyLines {
//    [Prefs setIndentEmptyLine:NO];
//    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleRemove];
//    
//    NSString *input = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace"];
//    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
//    
//    NSString *expected = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace_remove_noindent"];
//    XCTAssert([output isEqualToString:expected]);
//}

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
    XCTAssertEqual(outputCount, 1);
}

//- (void)test_breakBeforeOpeningBraceRuleForce {
//    [Prefs setIndentEmptyLine:YES];
//    [Prefs setIndent:INDENT_SPACE4];
//    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleForce];
//    
//    NSString *input = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace"];
//    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
//    
//    NSString *expected = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace_force"];
//    XCTAssert([output isEqualToString:expected]);
//}

//- (void)test_breakBeforeOpeningBraceRuleForce_noIndentationOfEmptyLines {
//    [Prefs setIndentEmptyLine:NO];
//    [self enableBreakBeforeOpeningBraceRule:SWMBreakBeforeOpeningBraceRuleForce];
//    
//    NSString *input = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace"];
//    NSString *output = [self.parser formatString:input withRange:NSMakeRange(0, input.length)];
//    
//    NSString *expected = [self stringFromSwiftFileNamed:@"breakBeforeOpeningBrace_force_noindent"];
//    XCTAssert([output isEqualToString:expected]);
//}

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

- (NSString *)stringFromSwiftFileNamed:(NSString *)filename
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filename ofType:nil];
    NSString *string = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    XCTAssertNotNil(string);
    return string;
}

@end
