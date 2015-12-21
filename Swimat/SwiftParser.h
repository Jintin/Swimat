#import <Foundation/Foundation.h>
#import "Parser.h"

@interface SwiftParser : Parser


-(NSString*) formatString:(NSString*) string withRange:(NSRange) range;
@end
