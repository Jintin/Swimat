#import <Foundation/Foundation.h>

@interface Parser : NSObject

+(bool) isSpace:(unichar) c;

+(bool) isBlank:(unichar) c;

+(bool) isQuote:(unichar) c;

+(bool) isUpperBrackets:(unichar) c;

+(bool) isLowerBrackets:(unichar) c;

/**
 @brief add string to next occurrence string
 */
-(NSUInteger) addStringToNext:(NSString *) next withOffset:(NSUInteger)index edit:(NSMutableString *) editString withString:(NSString *) string;

@end
