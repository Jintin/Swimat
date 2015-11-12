#import <Foundation/Foundation.h>
#import "Parser.h"

@interface SwiftParser : Parser

-(NSRange) getRange;

-(NSString*) formatString:(NSString*) string withRange:(NSRange) range;
@end
