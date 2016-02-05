#import "NSString+Common.h"

@implementation NSString (Common)

-(bool) isStartWith:(NSString *) string fromIndex:(NSUInteger) index {
	if (self.length >= index + string.length) {
		NSString *subString = [self substringWithRange:NSMakeRange(index, string.length)];
		return [subString isEqualToString:string];
	}
	return false;
}

-(NSString *) subString:(NSUInteger) startIndex endWith:(NSUInteger) endIndex {
	if (endIndex <= self.length) {
		return [self substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
	} else {
		return @"";
	}
}

-(NSString *) subString:(NSUInteger) startIndex length:(NSUInteger) length {
	if (startIndex + length <= self.length) {
		return [self substringWithRange:NSMakeRange(startIndex, length)];
	} else {
		return @"";
	}
}

-(bool) isCompleteLine:(NSUInteger) index {
	
	NSArray *array = [NSArray arrayWithObjects:@"+", @"-", @"*", @"/", @"=", @":", @".", @",", nil];
	
	bool(^notComplete)(NSUInteger checkIndex, NSArray* addition) = ^bool(NSUInteger checkIndex, NSArray* addition){
		if (checkIndex != -1) {
			NSString *checkString = [NSString stringWithFormat: @"%C", [self characterAtIndex:checkIndex]];
			if ([array containsObject:checkString] || [addition containsObject:checkString]) {
				return true;
			}
		}
		return false;
	};
	
	if (index < [self length] && [self characterAtIndex:index] != '\n') {
		index = [self nextIndex:index defaults:self.length compare:^bool(NSString *next, NSUInteger curIndex){
			return [next isEqualToString:@"\n"];
		}];
	}
	
	NSUInteger checkIndex = [self nextNonSpaceIndex:index + 1 defaults:-1];
	if (checkIndex != -1) {
		unichar nextChar = [self characterAtIndex:checkIndex];
		if (nextChar == '?') {
			return false;
		}
	}
	if (notComplete(checkIndex, nil)) {
		NSString *checkString = [self subString:checkIndex length:2];
		NSArray *exclude = [NSArray arrayWithObjects:@"++", @"--", @"//", @"/*", nil];
		if ([exclude containsObject:checkString]) {
			return true;
		}
		
		return false;
	}
	checkIndex = [self lastNonSpaceIndex:index - 1 defaults:-1];
	if (notComplete(checkIndex, @[@"(", @"["])) {
		unichar c = [self characterAtIndex:checkIndex];
		if (c == ':') {
			NSUInteger lineIndex = [self lastIndex:index - 1 defaults:self.length compare:^bool(NSString *last, NSUInteger curIndex){
				return [last isEqualToString:@"\n"];
			}];
			lineIndex = [self nextNonSpaceIndex:lineIndex defaults:-1];
			// check 'case' 'default'
			NSString *head = [self nextWord:lineIndex];
			if ([head hasPrefix:@"case"] || [head hasPrefix:@"default"]) {
				
				return true;
			}
		}
		if (checkIndex >= 2) {
			NSString *checkString = [self subString:checkIndex - 1 length:2];
			NSArray *exclude = [NSArray arrayWithObjects:@"++", @"--", @"//", @"/*", @"*/", nil];
			if ([exclude containsObject:checkString]) {
				return true;
			}
		}
		return false;
	}
	
	return true;
}

-(NSUInteger) nextIndex:(NSUInteger) index search:(NSString *) string defaults:(NSUInteger) value {
	
	NSRange range = [self rangeOfString:string options:0 range:NSMakeRange(index, [self length] - index)];
	if (range.location != NSNotFound) {
		return range.location + string.length;
	} else {
		return value;
	}
}

-(NSUInteger) nextIndex:(NSUInteger) index defaults:(NSUInteger) value compare: (bool(^)(NSString *, NSUInteger)) checker {
	if (index < self.length) {
		do {
			NSString *check = [self subString:index length:1];//TODO can change to char
			if (!checker(check, index)) {
				continue;
			}
			return index;
		} while (++index < self.length);
	}
	return value;
}

-(NSUInteger) nextQuoteIndex:(NSUInteger) index {
	bool escape = false;
	do {
		unichar next = [self characterAtIndex:index];
		
		if (next == '"' && !escape) {
			return index;
		}
		if (next == '\\') {
			escape = !escape;
		} else {
			escape = false;
		}
	} while (++index < self.length);
	if (index != self.length) {
		return index;
	} else {
		return -1;
	}
}

-(NSUInteger) nextSpaceIndex:(NSUInteger) index defaults:(NSUInteger) value {
	return [self nextIndex:index defaults:value compare:^bool(NSString *next, NSUInteger curIndex){
		return [next isEqualToString:@" "] || [next isEqualToString:@"\t"];
	}];
}

-(NSUInteger) nextNonSpaceIndex:(NSUInteger) index defaults:(NSUInteger) value {
	return [self nextIndex:index defaults:value compare:^bool(NSString *next, NSUInteger curIndex){
		return ![next isEqualToString:@" "] && ![next isEqualToString:@"\t"];
	}];
}

-(NSUInteger) nextCharIndex:(NSUInteger) index defaults:(NSUInteger) value {
	return [self nextIndex:index defaults:value compare:^bool(NSString *next, NSUInteger curIndex){
		return ![next isEqualToString:@" "] && ![next isEqualToString:@"\t"] && ![next isEqualToString:@"\n"];
	}];
}

-(NSUInteger) nextNonCharIndex:(NSUInteger) index defaults:(NSUInteger) value {
	return [self nextIndex:index defaults:value compare:^bool(NSString *next, NSUInteger curIndex){
		return [next isEqualToString:@" "] || [next isEqualToString:@"\t"] || [next isEqualToString:@"\n"];
	}];
}

-(unichar) nextChar:(NSUInteger) index defaults:(unichar) value {
	NSUInteger nextIndex = [self nextCharIndex:index defaults:-1];
	if (nextIndex == -1) {
		return value;
	} else {
		return [self characterAtIndex:nextIndex];
	}
}

-(NSString *) nextWord:(NSUInteger) index {
	NSUInteger fromIndex = [self nextCharIndex:index defaults:-1];
	NSUInteger toIndex = [self nextNonCharIndex:fromIndex defaults:self.length];
	if (fromIndex != -1) {
		return [self subString:fromIndex length:toIndex - fromIndex];
	}
	return nil;
}

-(NSUInteger) lastIndex:(NSUInteger) index defaults:(NSUInteger) value compare:(bool(^)(NSString *, NSUInteger)) checker {
	if ((int)index >= 0 && index < self.length) {
		do {
			NSString *check = [self subString:index length:1];
			if (!checker(check, index)) {
				continue;
			}
			return index;
		} while ((int)--index >= 0);
	}
	return value;
}

-(NSUInteger) lastSpaceIndex:(NSUInteger) index defaults:(NSUInteger) value {
	return [self lastIndex:index defaults:value compare:^bool(NSString *next, NSUInteger curIndex){
		return [next isEqualToString:@" "] || [next isEqualToString:@"\t"];
	}];
}

-(NSUInteger) lastNonSpaceIndex:(NSUInteger) index defaults:(NSUInteger) value {
	return [self lastIndex:index defaults:value compare:^bool(NSString *next, NSUInteger curIndex){
		return ![next isEqualToString:@" "] && ![next isEqualToString:@"\t"];
	}];
}

-(NSUInteger) lastCharIndex:(NSUInteger) index defaults:(NSUInteger) value {
	return [self lastIndex:index defaults:value compare:^bool(NSString *next, NSUInteger curIndex){
		return ![next isEqualToString:@" "] && ![next isEqualToString:@"\t"] && ![next isEqualToString:@"\n"];
	}];
}

-(NSUInteger) lastNonCharIndex:(NSUInteger) index defaults:(NSUInteger) value {
	return [self lastIndex:index defaults:value compare:^bool(NSString *next, NSUInteger curIndex){
		return [next isEqualToString:@" "] || [next isEqualToString:@"\t"] || [next isEqualToString:@"\n"];
	}];
}

-(unichar) lastChar:(NSUInteger) index defaults:(unichar) value {
	index = [self lastCharIndex:index defaults:-1];
	if (index != -1) {
		return [self characterAtIndex:index];
	}
	return value;
}

-(NSString *) lastWord:(NSUInteger) index {
	NSUInteger toIndex = [self lastCharIndex:index defaults:-1];
	NSUInteger fromIndex = [self lastNonCharIndex:toIndex defaults:-1];
	if (toIndex != -1) {
		return [self subString:fromIndex + 1 length:toIndex - fromIndex];
	}
	return nil;
}


@end
