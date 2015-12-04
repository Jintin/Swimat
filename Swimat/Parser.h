#import <Foundation/Foundation.h>

@interface Parser : NSObject

+(bool) isSpace:(unichar) c;

+(bool) isBlank:(unichar) c;

+(bool) isQuote:(unichar) c;

+(bool) isUpperBrackets:(unichar) c;

+(bool) isLowerBrackets:(unichar) c;

/**
 @brief is qualify name(0~9 a~z A~Z _)
 */
+(bool) isAZ:(unichar) c;

@end
