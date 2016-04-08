#import <Foundation/Foundation.h>

@interface Parser : NSObject

{
@public
	int indent;
	int onetimeIndent;
	NSMutableString *retString;
	NSString *orString;
	NSRange newRange;
	NSUInteger strIndex;
	NSString *indentString;
}

+(bool) isSpace:(unichar) c;

+(bool) isBlank:(unichar) c;

+(bool) isQuote:(unichar) c;

+(bool) isUpperBrackets:(unichar) c;

+(bool) isLowerBrackets:(unichar) c;

/**
 @brief is qualify name(0~9 a~z A~Z _)
 */
+(bool) isAZ:(unichar) c;

-(NSRange) getRange;

-(void) appendString:(NSString *) string;

-(void) appendChar:(unichar) c;

-(NSUInteger) spaceWith:(NSString *) string;

-(NSUInteger) spaceWithArray:(NSArray *) array;

-(int) trimWithIndent;

-(void) addIndent:(NSMutableString *)editString withCount:(int) count;

-(bool) isNext:(unichar) check;

-(bool) isNextString:(NSString *) check;

-(bool) isNextLineEmpty:(NSUInteger)index;

-(bool) isNextLineLowerBrackets:(NSUInteger)index;

-(bool) isEmptyLine;

-(NSUInteger) addToEnd:(NSString *) string edit:(NSMutableString *) editString withIndex:(NSUInteger) index;

@end
