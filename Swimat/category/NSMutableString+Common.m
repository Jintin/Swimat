#import "NSMutableString+Common.h"
#import "Parser.h"

@implementation NSMutableString(Common)

-(void) spaceWith:(NSString *)string {
	if (self.length != 0) {
		unichar c = [self characterAtIndex:self.length - 1];
		if (![Parser isBlank:c]) {
			[self appendString:@" "];
		}
	}
	[self appendString:string];
	[self appendString:@" "];
}

-(void) keepSpace {
	if (self.length != 0) {
		unichar c = [self characterAtIndex:self.length - 1];
		if (![Parser isBlank:c]) {
			[self appendString:@" "];
		}
	}
}

-(void) trim {
	while (self.length > 0 && [Parser isSpace:[self characterAtIndex:self.length - 1]]) {
		[self deleteCharactersInRange:NSMakeRange(self.length - 1, 1)];
	}
}
@end
