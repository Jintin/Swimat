#import "Parser.h"
#import "NSString+Common.h"
#import "NSMutableString+Common.h"

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

+(bool) isAZ:(unichar) c {
	if (c >= 48 && c <= 57) {//0~9
		return true;
	} else if (c >= 65 && c <= 90) {//A~Z
		return true;
	} else if (c >= 97 && c <= 122) {//a~z
		return true;
	} else if (c == 95) {//_
		return true;
	}
	return false;
}

-(NSRange) getRange {
	return newRange;
}

-(void) appendString:(NSString *) string {
	[retString appendString:string];
	
	NSString *trim = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	strIndex += trim.length;
}

-(void) appendChar:(unichar) c {
	[retString appendFormat:@"%c", c];
	strIndex++;
}

-(NSUInteger) spaceWith:(NSString *) string {
	[retString spaceWith:string];
	strIndex += string.length;
	return strIndex;
}

-(NSUInteger) spaceWithArray:(NSArray *) array {
	for (NSString *checkString in array) {
		if ([orString isStartWith:checkString fromIndex:strIndex]) {
			[self spaceWith:checkString];
			return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
		}
	}
	return -1;
}

-(void) trimWithIndent {
	[retString trim];
	if (retString.length > 0 && [retString characterAtIndex:retString.length - 1] == '\n') {
		[self addIndent:retString withCount:currentIndent];
	}
}

-(void) addIndent:(NSMutableString *)editString withCount:(int) count{
	for (int i = 0; i < count; i++) {
		[editString appendString:indentString];
	}
}

-(bool) isNext:(unichar) check {
	if (strIndex + 1 < orString.length) {
		return [orString characterAtIndex:strIndex + 1] == check;
	} else {
		return false;
	}
}

-(bool) isNextString:(NSString *) check {
	return [[orString subString:strIndex length:check.length] isEqualToString:check];
}

-(bool) isNextLineEmpty:(NSUInteger)index {
	NSUInteger nextNonSpaceIndex = [orString nextNonSpaceIndex:index defaults:retString.length];
	return nextNonSpaceIndex < orString.length ? [orString characterAtIndex:nextNonSpaceIndex] == '\n' : false;
}

-(bool) isNextLineLowerBrackets:(NSUInteger)index {
	NSUInteger nextNonSpaceIndex = [orString nextNonSpaceIndex:index defaults:retString.length];
	return nextNonSpaceIndex < orString.length ? [Parser isLowerBrackets:[orString characterAtIndex:nextNonSpaceIndex]] : false;
}

-(bool) isEmptyLine {
	NSUInteger lastNonSpaceIndex = [retString lastNonSpaceIndex:retString.length - 1 defaults:retString.length];
	return lastNonSpaceIndex < retString.length ? [retString characterAtIndex:lastNonSpaceIndex] == '\n' : false;
}

-(NSUInteger) addToEnd:(NSString *) string edit:(NSMutableString *) editString withIndex:(NSUInteger) index {
	NSUInteger nextIndex = [string nextIndex:index search:@"\n" defaults:-1];
	if (nextIndex == -1) { // not found '\n'
		[editString appendString:[string substringFromIndex:index]];
		[editString trim];
		return string.length;
	} else {
		[editString appendString:[string substringWithRange:NSMakeRange(index, nextIndex - index - 1)]];
		[editString trim];
		[editString appendString:@"\n"];
		return nextIndex;
	}
}

@end
