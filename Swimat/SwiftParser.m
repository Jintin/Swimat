#import "Parser.h"
#import "SwiftParser.h"
#import "NSString+Common.h"
#import "NSMutableString+Common.h"
#import "Prefs.h"

@implementation SwiftParser

bool inSwitch; // TODO: change to stack if need nested
int switchBlockCount; // change to stack if need nested
bool indentEmptyLine;
NSMutableArray *blockStack;
NSString *curBlock;
NSMutableArray *indentStack;
NSMutableArray *onetimeIndentStack;
int curIndent = 0;

-(NSString*) formatString:(NSString*) string withRange:(NSRange) range {
	NSDate *methodStart = [NSDate date];
	bool checkRangeStart = false, checkRangeEnd = range.length == 0;
	strIndex = 0;
	indent = 0;
	curIndent = 0;
	onetimeIndent = 0;
	curBlock = @"";
	blockStack = [NSMutableArray array];
	indentStack = [NSMutableArray array];
	onetimeIndentStack = [NSMutableArray array];
	orString = string;
	retString = [NSMutableString string];
	inSwitch = false;
	switchBlockCount = 0;
	indentString = [Prefs getIndentString];
	indentEmptyLine = [Prefs isIndentEmptyLine];
	
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
#if DEBUG
            NSLog(@"modify range location");
#endif
	}
	if (newRange.location + newRange.length >= retString.length) {
		newRange.length = retString.length - newRange.location;
#if DEBUG
		NSLog(@"modify range length");
#endif
	}
	NSDate *methodFinish = [NSDate date];
	NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
#if DEBUG
	NSLog(@"format executionTime = %f", executionTime);
#endif
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
//			[retString keepSpace];
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

-(NSUInteger) findNextEscape:(NSUInteger) index {
//	NSMutableString *tempString = [NSMutableString string];
	bool escape = false;
	int count = 1;
	while (count != 0 && ++index < orString.length) {
		unichar next = [orString characterAtIndex:index];
		if (!escape) {
			if (next == '(') {
				count++;
			} else if (next == ')') {
				count--;
			} else if (next == '"') {
				index = [self findNextQuote:index];
			}
		}
		
		if (next == '\\') {
			escape = !escape;
		} else {
			escape = false;
		}
	}
	if (index < orString.length) {
		return index;
	} else {
		return -1;
	}
	
}

-(NSUInteger) findNextQuote:(NSUInteger) index {
//	NSMutableString *tempString = [NSMutableString string];
	bool escape = false;
	while (++index < orString.length) {
		unichar next = [orString characterAtIndex:index];
		if (next == '"' && !escape) {
			return index;
		}
		if (next == '(' && escape) {
			NSUInteger start = index;
			index = [self findNextEscape:index];
			
			if (index != -1) {
				NSString *sub = [orString subString:start + 1 endWith:index];
//				SwiftParser *parser = [[SwiftParser alloc] init];
//				NSString *string = [parser formatString: sub withRange:NSMakeRange(0, sub.length)];
//				//TODO modify back
#if DEBUG
				NSLog(@"sub string '%@' ", sub);
#endif
			} else {
				return index;
			}
			escape = false;
		}
		if (next == '\\') {
			escape = !escape;
		} else {
			escape = false;
		}
	}
	return -1;
}

-(NSUInteger) checkQuote:(unichar) c {
	if (c == '"') {
		NSUInteger nextIndex = [self findNextQuote:strIndex] + 1;

		if (nextIndex == 0) {
			nextIndex = orString.length;
		}
		NSString *quoteString = [orString substringWithRange:NSMakeRange(strIndex, nextIndex - strIndex)];
		
		[retString appendString:quoteString];
		return nextIndex;
	}
	return 0;
}

-(NSUInteger) checkNewline:(unichar) c {
	if (c == '\n') {
		if (![orString isCompleteLine:strIndex curBlock:curBlock]) {
			onetimeIndent++;
		}
		BOOL shouldAddEmtyLine = !([self isEmptyLine] && ([self isNextLineEmpty:strIndex + 1] || [self isNextLineLowerBrackets:strIndex + 1]));
		if (indentEmptyLine) {
			[self trimWithIndent];
		} else {
			[retString trim];
		}
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
		{
			NSArray *array = @[@"+++=", @"+++", @"+=<", @"+="];
			NSUInteger findIndex = [self spaceWithArray:array];
			if (findIndex != -1) {
				return findIndex;
			} else if ([self isNext:'+']) { // ++
				[self appendString:@"++"];
				return strIndex;
			} else { // +, ignore positive sign
				[self spaceWith:@"+"];
				return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
			}
		}
		case '-':
			if ([self isNext:'-']) { // --
				[self appendString:@"--"];
				return strIndex;
			} else if ([self isNext:'>']) { // ->
				[self spaceWith:@"->"];
			} else if ([self isNext:'=']) { // -=
				[self spaceWith:@"-="];
			} else if ([self isNextString:@"-<<"]) {
				[self spaceWith:@"-<<"];
			} else { // -
				NSArray *checkChar = @[@"+",@"-",@"*",@"/",@"&",@"|",@"^",@"<",@">",@":",@"(",@"{",@"?",@"!",@"=",@","];
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
		{
			NSArray *array = @[@"~=", @"~~>"];
			NSUInteger findIndex = [self spaceWithArray:array];
			if (findIndex != -1) {
				return findIndex;
			}
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
			if ([self isNext:'#']) {
				[self appendString:@"<#"];
				return strIndex;
			}
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
				NSString *regex = @"^(<|>|\\[|\\]|\\(|\\)|\\.|:|\\w|\\s|!|\\?|,)+$";
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
			NSArray *array = @[@"<<<", @"<<=", @"<<", @"<=", @"<~~", @"<~", @"<--", @"<-<", @"<-", @"<*>", @"<^>", @"<||?", @"<||", @"<|?", @"<|>", @"<|"];
			NSUInteger findIndex = [self spaceWithArray:array];
			if (findIndex != -1) {
				return findIndex;
			}
			return [self spaceWith:@"<"];
		}
		case '>':
		{
			NSArray *array = @[@">>>", @">>=", @">>-", @">>", @">=", @">->", @">"];
			return [self spaceWithArray:array];
		}
		case '|':
		{
			NSArray *array = @[[NSString stringWithFormat:@"%c%c%c", c, c, c],
							   [NSString stringWithFormat:@"%c%c=", c, c],
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
			//			if ([self isNext:'?']) { // how to distingush two optional ?? or null check ??
			//				[self spaceWith:@"??"];
			//				return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
			//			}
			return 0;
		case ':':
		{
			if ([self isNext:'?']) {
				[self spaceWith:@":?"];
				return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
			}
			bool findBlock = false;
			bool isInlineIf = false;
			NSUInteger searchIndex = [retString lastNonBlankIndex:retString.length - 1 defaults:-1];
			
			while (!findBlock) {
				if (searchIndex == -1) {
					findBlock = true;
					break;
				}
				unichar now = [retString characterAtIndex:searchIndex];
				if (now == '?') {
					if (searchIndex + 1 < retString.length && [retString characterAtIndex:searchIndex + 1] != '.') {
						isInlineIf = true;
						findBlock = true;
					} else {
						searchIndex--;
					}
				} else if (now == '"') {
					searchIndex = [retString lastIndex:searchIndex - 1 defaults:-1 compare:^bool(NSString *last, NSUInteger curIndex) {
						if ([last isEqualToString:@"\""]) {
							if (curIndex != 0 && [retString characterAtIndex:curIndex - 1] != '\\') {
								return true;
							}
						}
						return false;
					}];
					if (searchIndex != -1) {
						searchIndex--;
					} else {
						findBlock = true;
					}
				} else if ([Parser isBlank:now]){
					searchIndex = [retString lastNonBlankIndex:searchIndex defaults:-1];
					if (searchIndex != -1 && [retString characterAtIndex:searchIndex] == '?') {
						if ([retString characterAtIndex:searchIndex + 1] != '.') {
							isInlineIf = true;
						}
					}
					findBlock = true;
				} else if (now == ')') {
					__block int blockCount = 0;
					searchIndex = [retString lastIndex:searchIndex defaults:-1 compare:^bool(NSString *last, NSUInteger curIndex) {
						if ([last isEqualToString:@")"]) {
							blockCount++;
						} else if ([last isEqualToString:@"("]) {
							blockCount--;
						}
						
						return blockCount == 0;
					}];
					if (searchIndex != -1) {
						searchIndex--;
					} else {
						findBlock = true;
					}
				} else if ([Parser isUpperBrackets:now]) {
					findBlock = true;
				} else {
					searchIndex--;
				}
			}
			if (isInlineIf) {
				if (![Parser isBlank:[retString characterAtIndex:searchIndex + 1]]) {
					[retString insertString:@" " atIndex:searchIndex + 1];
				}
				if (![Parser isBlank:[retString characterAtIndex:searchIndex - 1]]) {
					[retString insertString:@" " atIndex:searchIndex];
				}
				[self spaceWith:@":"];
			} else {
				[self trimWithIndent];
				[self appendString:@": "];
			}
			return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
		}
		case '.':
			if (orString.length >= strIndex + 3) {
				NSString *leading = [orString substringWithRange:NSMakeRange(strIndex, 3)];
				if ([leading isEqualToString:@"..."] || [leading isEqualToString:@"..<"]) {
					[self spaceWith:leading];
				} else {
					[self appendString:@"."];
				}
			} else {
				[self appendString:@"."];
			}
			return [orString nextNonSpaceIndex:strIndex defaults:orString.length];
		case '#':
			if ([self isNextString:@"#if"]) {
				indent++;
				[self appendString:@"#if"];
				return strIndex;
			} else if ([self isNextString:@"#else"]) {
				indent--;
				[retString trim];
				[self addIndent:retString];
				indent++;
				[self appendString:@"#else"];
				return strIndex;
			} else if ([self isNextString:@"#endif"]) {
				indent--;
				[retString trim];
				[self addIndent:retString];
				[self appendString:@"#endif"];
				return strIndex;
			} else if ([self isNext:'>']) {
				[self appendString:@"#>"];
				return strIndex;
			} else if ([self isNext:'!']) {
				return [self addToEnd:orString edit:retString withIndex:strIndex];
			}
			break;
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
	curIndent = indent + onetimeIndent;
	[self addIndent:editString withCount:curIndent];
	onetimeIndent = 0;
	return nextIndex;
}

-(NSUInteger) checkBrackets:(unichar) c {
	if ([Parser isUpperBrackets:c]) {
		[indentStack addObject:[NSNumber numberWithInt:indent]];
		[onetimeIndentStack addObject:[NSNumber numberWithInt:onetimeIndent]];
		curBlock = [NSString stringWithFormat:@"%c", c];
		[blockStack addObject:curBlock];
		
		if (inSwitch && c == '{') {
			switchBlockCount++;
		}
		
		unichar lastChar = [orString lastChar:strIndex - 1 defaults:'\n'];
		
		if ([Parser isLowerBrackets:lastChar]) {
			if (c == '{') {
				[retString keepSpace];
			} else {
				[self trimWithIndent];
			}
		} else {
			switch (c) {
				case '(':{
					NSArray *controlsArray = @[ @"if", @"else", @"while", @"for", @"guard", @"switch", @"case", @"defer", @"var", @"let", @"return", @"#if", @"#else", @"#endif"];
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
		if (c == '{') {
			[self appendString:@" "];
		}
		indent = curIndent + 1;
		return [orString nextNonSpaceIndex:strIndex defaults:strIndex];
	} else if ([Parser isLowerBrackets:c]) {
		if (inSwitch && c == '}') {
			if (--switchBlockCount == 0) {
				inSwitch = false;
			}
		}
		
		indent = [[indentStack lastObject] intValue];
		[indentStack removeLastObject];
		[blockStack removeLastObject];
		curBlock = [blockStack lastObject];
		onetimeIndent = [[onetimeIndentStack lastObject] intValue];
		[onetimeIndentStack removeLastObject];
		[self trimWithIndent];
		
		unichar lastChar = [retString characterAtIndex:retString.length - 1];
		if ([Parser isLowerBrackets:lastChar]) {
			[retString deleteCharactersInRange:NSMakeRange(retString.length - 1, 1)];
			int count = [self trimWithIndent];
			if (count != 0) {
				[retString appendFormat:@"%c", ' '];
			}
			[retString appendFormat:@"%c", lastChar];
		}
		
		if (c == '}' && retString.length > 0) {
			unichar lastChar = [retString characterAtIndex:retString.length - 1];
			if (![Parser isBlank:lastChar]) {
				[self appendString:@" "];
			}
		}
		[self appendChar:c];
		
		unichar next = [orString nextChar:strIndex defaults:' '];
		if (next == '?' || next == ':' || [Parser isLowerBrackets:next]) {
			return strIndex;
		} else if (next != '.' && next != '!' && next != ';') {
			[retString keepSpace];
		}
		return [orString nextNonSpaceIndex:strIndex defaults:strIndex];
	}
	
	return 0;
}

@end
