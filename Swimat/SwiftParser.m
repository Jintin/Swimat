#import "Parser.h"
#import "SwiftParser.h"
#import "NSString+Common.h"
#import "NSMutableString+Common.h"
#import "Prefs.h"

@implementation SwiftParser

bool inSwitch; // TODO: change to stack if need nested
int switchBlockCount; // change to stack if need nested

-(NSString*) formatString:(NSString*) string withRange:(NSRange) range {
	NSDate *methodStart = [NSDate date];
	bool checkRangeStart = false, checkRangeEnd = range.length == 0;
	strIndex = 0;
	indent = 0;
	onetimeIndent = 0;
	currentIndent = 0;
	orString = string;
	retString = [NSMutableString string];
	inSwitch = false;
	switchBlockCount = 0;
	indentString = [Prefs getIndentString];
	
	newRange = NSMakeRange(range.location, range.length);// TODO need?
	
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
			checkRangeStart = true;
			newRange.location = [self transformIndex:range.location];
			
			if (range.length != 0) {
				[retString replaceCharactersInRange:NSMakeRange(0, newRange.location) withString:[string substringWithRange:NSMakeRange(0, range.location)]];
				newRange.location = range.location;
			}
		}
		if (!checkRangeEnd && strIndex >= range.location + range.length) {
			checkRangeEnd = true;
			NSUInteger temp = [self transformIndex:range.location + range.length];
			newRange.length = temp - newRange.location;
			
			if (range.length != 0) {
				[retString replaceCharactersInRange:NSMakeRange(newRange.location + newRange.length, retString.length - newRange.location - newRange.length) withString:[string substringWithRange:NSMakeRange(range.location + range.length, string.length - range.location - range.length)]];
				break;
			}
		}
	}
	[retString trim];
	if (newRange.location >= retString.length) {
		newRange.location = retString.length;
		NSLog(@"modify range location");
	}
	if (newRange.location + newRange.length >= retString.length) {
		newRange.length = retString.length - newRange.location;
		NSLog(@"modify range length");
	}
	NSDate *methodFinish = [NSDate date];
	NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
	NSLog(@"format executionTime = %f", executionTime);
	return retString;
}

-(NSUInteger) transformIndex:(NSUInteger) rangeIndex {
	if (rangeIndex == 0) {
		return 0;
	}
	NSUInteger index1 = strIndex - 1;
	NSUInteger index2 = [retString lastNonSpaceIndex:retString.length - 1 defaults:0];
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

-(NSUInteger) lineComment:(bool) trim {
	strIndex = [orString nextIndex:strIndex defaults:orString.length compare:^bool(NSString *next, NSUInteger curIndex){
		if ([next isEqualToString:@"/"]) {
			[self appendString:@"/"];
			return false;
		}
		return true;
	}];
	if (trim) {
		[self appendString:@" "];
		strIndex = [orString nextNonSpaceIndex:strIndex defaults:orString.length];
	}
	strIndex = [self addToEnd:orString edit:retString withIndex:strIndex];
	
	return [self addIndent:retString];
}

-(NSUInteger) checkComment:(unichar) c {
	if (c == '/') {
	
		if ([self isNext:'/']) {
			return [self lineComment:true];
		} else if ([self isNext:'*']) {
			NSUInteger nextIndex = [orString nextIndex:strIndex search:@"*/" defaults:orString.length];
			
			NSString *subString = [orString substringWithRange:NSMakeRange(strIndex, nextIndex - strIndex)];
			NSMutableString *orderStr = [NSMutableString string];
			NSUInteger subIndex = 0;
			while (subIndex < subString.length) {
				subIndex = [subString nextNonSpaceIndex:subIndex defaults:subIndex];
				NSUInteger newIndex = [self addToEnd:subString edit:orderStr withIndex:subIndex];
				[self addIndent:orderStr withCount:indent];
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
		BOOL shouldAddEmtyLine = !([self isEmptyLine] && ([self isNextLineEmpty:strIndex + 1] || [self isNextLineLowerBrackets:strIndex + 1]));
		[self trimWithIndent];
		if (shouldAddEmtyLine) {
			[self appendString:@"\n"];
		} else {
			strIndex++;
		}
		
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
		[self trimWithIndent];
		[self appendString:@", "];
		return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
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
				NSArray *checkWord = @[@"case", @"return", @"if", @"for", @"while"];
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
		case '~':
			if ([self isNext:'=']) {
				[self spaceWith:[NSString stringWithFormat:@"%c=", c]];
				return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
			} else {
				return 0;
			}
		case '*':
		case '/':
		case '%':
		case '^':
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
						checkString = [checkString stringByReplacingOccurrencesOfString:@"," withString:@", "];
						checkString = [checkString stringByReplacingOccurrencesOfString:@":" withString:@": "];
						while ([checkString containsString:@"  "]) {
							checkString = [checkString stringByReplacingOccurrencesOfString:@"  " withString:@" "];
						}
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
	if ([self isNextString:@"//"]) { // code comment not indent
		return [self lineComment:false];
	}
	NSUInteger nextIndex = [orString nextNonSpaceIndex:strIndex defaults:-1];

	if (nextIndex == -1) {
		return strIndex + 1;
	}
	if ([@"switch" isEqualToString:[orString nextWord:strIndex]]) {
		inSwitch = true;
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
	currentIndent = indent + onetimeIndent;
	[self addIndent:editString withCount:currentIndent];
	onetimeIndent = 0;
	return nextIndex;
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
				[self trimWithIndent];
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
						[self trimWithIndent];
					}
				}
					break;
				case '{':
					if (![Parser isUpperBrackets:lastChar]) {
						[retString keepSpace];
					}
					break;
				default:
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
		[self trimWithIndent];
		[self appendChar:c];
		
		unichar next = [orString nextChar:strIndex defaults:' '];
		if (next == '?' || next == ':') {
			return strIndex;
		} else if (next != '.' && next != '!') {
			[retString keepSpace];
		}
		return [orString nextNonSpaceIndex:strIndex defaults:strIndex];
	}
	
	return 0;
}

@end
