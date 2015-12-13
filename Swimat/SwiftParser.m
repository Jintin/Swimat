#import "Parser.h"
#import "SwiftParser.h"
#import "NSString+Common.h"
#import "NSMutableString+Common.h"

@implementation SwiftParser

int indent;
int onetimeIndent;
int lastIndent;
NSMutableString *retString;
NSString *orString;
NSRange newRange;
NSUInteger strIndex;


bool inSwitch; // TODO: change to stack if need nested
int switchBlockCount; // change to stack if need nested

-(NSRange) getRange {
	return newRange;
}

-(NSString*) formatString:(NSString*) string withRange:(NSRange) range {
	
	bool checkRangeStart = false, checkRangeEnd = false;
	strIndex = 0;
	indent = 0;
	onetimeIndent = 0;
	lastIndent = 0;
	orString = string;
	retString = [NSMutableString string];
	inSwitch = false;
	switchBlockCount = 0;
	
	NSUInteger length = [string lastNonSpaceIndex:range.location + range.length defaults:range.location + range.length] - range.location;
	NSUInteger location = [string nextNonSpaceIndex:range.location defaults:range.location];
	newRange = NSMakeRange(location, length);
	
	while (strIndex < string.length) {
		unichar c = [string characterAtIndex:strIndex];
		
		NSUInteger nextIndex = 0;
		
		if ((nextIndex = [self checkComment:c]) != 0) {
			strIndex = nextIndex;
		} else if ((nextIndex = [self checkQuote:c]) != 0) {
			strIndex = nextIndex;
		} else if ((nextIndex = [self checkBrackets:c]) != 0) {
			strIndex = nextIndex;
		} else if ((nextIndex = [self checkNewline:c]) != 0) {
			strIndex = nextIndex;
		} else if ((nextIndex = [self checkSpace:c]) != 0) {
			strIndex = nextIndex;
		} else if ((nextIndex = [self checkComma:c]) != 0) {
			strIndex = nextIndex;
		} else if ((nextIndex = [self checkOperator:c]) != 0) {
			strIndex = nextIndex;
		} else {
			[self appendChar:c];
		}
		if (!checkRangeStart && strIndex >= range.location) {
			newRange.location = [self transformIndex:range.location];
			checkRangeStart = true;
			if (range.length == 0) {
				checkRangeEnd = true;
				newRange.length = 0;
			}
		}
		if (!checkRangeEnd && strIndex >= range.location + range.length) {
			NSUInteger temp = [self transformIndex:range.location + range.length];
			newRange.length = temp - newRange.location;
			checkRangeEnd = true;
		}
	}
	[retString trim];
	if (newRange.location >= retString.length) {
		newRange.location = retString.length;
	}
	if (newRange.location + newRange.length >= retString.length) {
		newRange.length = retString.length - newRange.location;
	}
	return retString;
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

-(NSUInteger) transformIndex:(NSUInteger) rangeIndex {
	NSUInteger index1 = strIndex - 1;
	NSUInteger index2 = retString.length - 1;
	
	if (strIndex >= orString.length) {
		index1 = orString.length - 1;
	}
	
	bool samevalue = true;
	while (index1 >= rangeIndex) {
		if ([Parser isSpace:[orString characterAtIndex:index1]]) {
			index1--;
			samevalue = false;
		}
		if ([Parser isSpace:[retString characterAtIndex:index2]]) {
			index2--;
			samevalue = false;
		}
		if (samevalue) {
			index1--;
			index2--;
		} else {
			samevalue = true;
		}
		if (index1 + 1 == 0 || index2 + 1 == 0) {// no negative value here
			return 0;
		}
	}
	return index2 + 1;
}

-(bool) isNext:(unichar) check {
	return [orString characterAtIndex:strIndex + 1] == check;
}

-(NSUInteger) checkComment:(unichar) c {
	if (c == '/') {
		
		NSUInteger (^addToEnd)(NSString *, NSMutableString *, NSUInteger) =
		^ NSUInteger (NSString *string, NSMutableString *editString, NSUInteger index) {
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
		};
		
		if ([self isNext:'/']) {
			[self appendString:@"//"];
			strIndex = addToEnd(orString, retString, strIndex);
			
			return [self addIndent:retString];
		} else if ([self isNext:'*']) {
			NSUInteger nextIndex = [orString nextIndex:strIndex search:@"*/" defaults:orString.length];
			
			NSString *subString = [orString substringWithRange:NSMakeRange(strIndex, nextIndex - strIndex)];
			NSMutableString *orderStr = [NSMutableString string];
			NSUInteger subIndex = 0;
			while (subIndex < subString.length) {
				subIndex = [subString nextNonSpaceIndex:subIndex defaults:subIndex];
				NSUInteger newIndex = addToEnd(subString, orderStr, subIndex);
				
				for (int i = 0; i < indent; i++) {
					[orderStr appendString:@"\t"];
				}
				subIndex = newIndex;
				if (subIndex < subString.length) {
					[orderStr appendString:@" "];
				}
			}
			
			[retString appendString:orderStr];
			return nextIndex;
		}
	}
	
	return 0;
}

-(NSUInteger) checkQuote:(unichar) c {
	if (c == '"') {
		NSUInteger nextIndex = [orString nextQuoteIndex:strIndex + 1] + 1;
		[retString appendString:[orString substringWithRange:NSMakeRange(strIndex, nextIndex - strIndex)]];
		return nextIndex;
	}
	return 0;
}

-(NSUInteger) checkNewline:(unichar) c {
	if (c == '\n') {
		if (![orString isCompleteLine:strIndex]) {
			onetimeIndent++;
		}
		[retString trim];
		[self appendString:@"\n"];
		return [self addIndent:retString];
	}
	
	
	return 0;
}

-(NSUInteger) checkSpace:(unichar) c {
	if ([Parser isSpace:c]) {
		[retString keepSpace];
		return [orString nextNonSpaceIndex:strIndex defaults:strIndex + 1];
	}
	
	return 0;
}

-(NSUInteger) checkComma:(unichar) c {
	if (c == ',') {
		[retString trim];
		if (retString.length > 0 && [retString characterAtIndex:retString.length - 1] == '\n') {
			[self addIndent:retString withCount:lastIndent];
		}
		NSUInteger nextIndex = [orString nextNonSpaceIndex:strIndex + 1 defaults:-1];
		if (nextIndex != -1 && [orString characterAtIndex:nextIndex] != '\n') {
			[retString appendString:@", "];
		} else {
			[retString appendString:@","];
		}
		return nextIndex != -1 ? nextIndex : strIndex + 1;
	}
	
	return 0;
}

-(NSUInteger) checkOperator:(unichar) c {
	
	switch (c) {
		case '+':
			if ([self isNext:'+']) { // ++
				[self appendString:@"++"];
				return strIndex;
			} else if ([self isNext:'=']) { // +=
				[self spaceWith:@"+="];
			} else { // +, ignore positive sign
				[self spaceWith:@"+"];
			}
			return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
		case '-':
			if ([self isNext:'-']) { // --
				[self appendString:@"--"];
				return strIndex;
			} else if ([self isNext:'>']) { // ->
				[self spaceWith:@"->"];
			} else if ([self isNext:'=']) { // -=
				[self spaceWith:@"-="];
			} else { // -
				NSArray *checkChar = @[@"+",@"-",@"*",@"/",@"&",@"|",@"^",@":",@"(",@"{",@"?",@"!",@"=",@","];
				unichar last = [orString lastChar:strIndex - 1 defaults:' '];
				NSArray *checkWord = @[@"case", @"return"];
				NSString *lastWord = [orString lastWord:strIndex - 1];
				
				bool isNegative = false;
				if ([checkChar containsObject:[NSString stringWithFormat:@"%c", last]]) {
					isNegative = true;
				} else if ([checkWord containsObject:lastWord]) {
					isNegative = true;
				}
				if (isNegative) {
					if (![Parser isUpperBrackets:last] && ![Parser isBlank:[retString characterAtIndex:retString.length - 1]]) {
						[retString keepSpace];
					}
					[self appendString:@"-"];
				} else {
					[self spaceWith:@"-"];
				}
			}
			return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
		case '*':
		case '/':
		case '%':
		case '^':
		case '~':
			if ([self isNext:'=']) { // *=, /=, >=, <=
				[self spaceWith:[NSString stringWithFormat:@"%c=", c]];
			} else { // * /
				[self spaceWith:[NSString stringWithFormat:@"%c", c]];
			}
			return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
		case '&':
		{
			NSArray *array = @[@"&+", @"&-", @"&*", @"&/", @"&%", @"&&=", @"&&", @"&="];
			NSUInteger findIndex = [self spaceWithArray:array];
			if (findIndex != -1) {
				return findIndex;
			}
			return 0; // TODO check if pointer or normal &
		}
		case '<':
		{
			NSArray *array = @[@"<<=", @"<<", @"<="];
			NSUInteger findIndex = [self spaceWithArray:array];
			if (findIndex != -1) {
				return findIndex;
			} else {
				NSUInteger checkIndex = strIndex;
				__block int checkCount = 0;
				NSUInteger closeIndex = [orString nextIndex:checkIndex defaults:-1 compare:^bool(NSString *next, NSUInteger curIndex){
					if ([next isEqualToString:@"<"]) {
						checkCount++;
					} else if ([next isEqualToString:@">"]) {
						return --checkCount == 0;
					}
					return false;
				}];
				
				if (closeIndex != -1) {
					NSString *checkString = [orString subString:checkIndex endWith:closeIndex + 1];
					
					NSString *regex = @"^(<|>|\\.|:|\\w|\\s|!|\\?|,)+$";
					NSRange range = [checkString rangeOfString:regex options:NSRegularExpressionSearch];
					if (range.location != NSNotFound) {
						strIndex += checkString.length;
						checkString = [checkString stringByReplacingOccurrencesOfString:@" " withString:@""];
						checkString = [checkString stringByReplacingOccurrencesOfString:@"," withString:@", "];
						
						[retString appendString:checkString];
						return strIndex;
					}
				}
				return [self spaceWith:@"<"];
			}
		}
		case '>':
		case '|':
		{
			NSArray *array = @[[NSString stringWithFormat:@"%c%c=", c, c],
							   [NSString stringWithFormat:@"%c%c", c, c],
							   [NSString stringWithFormat:@"%c=", c],
							   [NSString stringWithFormat:@"%c", c]];
			return [self spaceWithArray:array];
		}
		case '!':
		{
			NSArray *array = @[@"!==", @"!="];
			NSUInteger findIndex = [self spaceWithArray:array];
			if (findIndex != -1) {
				return findIndex;
			} else {
				return 0;
			}
		}
		case '=': // =
		{
			NSArray *array = @[@"===", @"==", @"="];
			NSUInteger findIndex = [self spaceWithArray:array];
			return findIndex;
		}
		case '?':
			if ([self isNext:'?']) {
				[self spaceWith:@"??"];
			} else {
				//				__block int count = 0;
				//				NSUInteger nextIndex = orString nextIndex:strIndex defaults:-1 compare:^bool(NSString *next){
				//					if (<#condition#>) {
				//						<#statements#>
				//					}
				//					return [next isEqualToString:@":"];
				//				}];
				//
				//				[orString nextIndex:strIndex search:@":" defaults:orString.length];
				//				if (nextIndex != -1) {
				//
				//				}
				
				return 0; // TODO check (optional)? or A?B:C
			}
			return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
		case ':':
			[self appendString:@": "];
			return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
		case '.':
			if (orString.length >= strIndex + 3) {
				NSString *leading = [orString substringWithRange:NSMakeRange(strIndex, 3)];
				if ([leading isEqualToString:@"..."] || [leading isEqualToString:@"..<"]) {
					[self appendString:leading];
				} else {
					[self appendString:@"."];
				}
			} else {
				[self appendString:@"."];
			}
			return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
			
		default:
			break;
	}
	return 0;
}

-(NSUInteger) addIndent:(NSMutableString *)editString  {
	
	NSUInteger nextIndex = [orString nextNonSpaceIndex:strIndex defaults:-1];
	if ([@"switch" isEqualToString:[orString nextWord:strIndex]]) {
		inSwitch = true;
	}
	if (nextIndex == -1) {
		return strIndex + 1;
	}
	unichar next = [orString characterAtIndex:nextIndex];
	if ([Parser isLowerBrackets:next]) { // close bracket don't indent
		onetimeIndent -= 1;
	}
	NSString *head = [orString nextWord:nextIndex];
	
	// check in switch block
	NSArray *array = @[@"case", @"default:"];
	if (inSwitch && [array containsObject:head]) {//TODO change contains to startWith will better
		onetimeIndent -= 1;
	}
	lastIndent = indent + onetimeIndent;
	[self addIndent:editString withCount:indent + onetimeIndent];
	onetimeIndent = 0;
	return nextIndex;
}

-(void) addIndent:(NSMutableString *)editString withCount:(int) count{
	for (int i = 0; i < count; i++) {
		[editString appendString:@"\t"];
	}
}

-(NSUInteger) checkBrackets:(unichar) c {
	
	if ([Parser isUpperBrackets:c]) {
		indent++;
		if (inSwitch && c == '{') {
			switchBlockCount++;
		}
		
		unichar lastChar = [orString lastChar:strIndex - 1 defaults:' '];
		
		if ([Parser isLowerBrackets:lastChar]) {
			if (c == '(') {
				[retString trim];
			} else {
				[retString keepSpace];
			}
		} else {
			switch (c) {
				case '(':{
					NSArray *controlsArray = @[ @"if", @"else", @"while", @"for", @"guard", @"switch", @"case", @"defer", @"var", @"let", @"return"];
					NSString *preStr = [orString lastWord:strIndex - 1];
					if ([controlsArray containsObject:preStr]) {
						[retString keepSpace];
					} else if ([Parser isAZ:lastChar] || lastChar == ']'){
						[retString trim];
						if ([retString characterAtIndex:retString.length - 1] == '\n') {
							[self addIndent:retString withCount:lastIndent];
						}
					}
				}
					break;
				case '{':
					if (![Parser isUpperBrackets:lastChar]) {
						[retString keepSpace];
					}
					break;
				defaults:
					break;
			}
		}
		[self appendChar:c];
		
		return [orString nextNonSpaceIndex:strIndex defaults:strIndex];
	} else if ([Parser isLowerBrackets:c]) {
		if (inSwitch && c == '}') {
			if (--switchBlockCount == 0) {
				inSwitch = false;
			}
		}
		if (indent != 0)
			indent--;
		[retString trim];
		if (retString.length > 0 && [retString characterAtIndex:retString.length - 1] == '\n') {
			[self addIndent:retString withCount:lastIndent];
		}
		[self appendChar:c];
		unichar next = [orString nextChar:strIndex defaults:' '];
		if (next != '.' && next != '?' && next != '!') {
			[retString keepSpace];
		}
		return [orString nextNonSpaceIndex:strIndex defaults:strIndex];
	}
	
	return 0;
}

@end
