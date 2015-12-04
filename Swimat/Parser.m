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

@end
