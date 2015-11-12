#import "Parser.h"
#import "NSString+Common.h"

@implementation Parser

+(bool) isSpace:(unichar) c {
	return c == '\t' || c == ' ';
}

+(bool) isBlank:(unichar) c {
	return c == '\t' || c == ' ' || c == '\n';
}

+(bool) isQuote:(unichar) c {
	return c == '"';
}

+(bool) isUpperBrackets:(unichar) c {
	return c == '(' || c == '{' || c == '[';
}

+(bool) isLowerBrackets:(unichar) c {
	return c == ')' || c == '}' || c == ']';
}

-(NSUInteger) addStringToNext:(NSString *) next withOffset:(NSUInteger)index edit:(NSMutableString *) editString withString:(NSString *) string {
	
	NSUInteger nextIndex = [string nextIndex:index search:next defaults:string.length];
	
	[editString appendString:[string substringWithRange:NSMakeRange(index, nextIndex - index)]];
	return nextIndex;
}

@end
