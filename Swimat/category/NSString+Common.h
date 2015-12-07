#import <Foundation/Foundation.h>

@interface NSString (Common)

/**
 @brief check self is start with string from index
 */
-(bool) isStartWith:(NSString *) string fromIndex:(NSUInteger) index;

/**
 @brief substring with start and end index
 */
-(NSString *) subString:(NSUInteger) startIndex endWith:(NSUInteger) endIndex;

/**
 @brief substring with start index and length
 */
-(NSString *) subString:(NSUInteger) startIndex length:(NSUInteger) length;

/**
 @brief is complete line of code or not
 */
-(bool) isCompleteLine:(NSUInteger) index;

/**
 @brief find next index by given sting
 */
-(NSUInteger) nextIndex:(NSUInteger) index search:(NSString *) string defaults:(NSUInteger) value;

/**
 @brief find next index of string
 */
-(NSUInteger) nextIndex:(NSUInteger) index defaults:(NSUInteger) value compare: (bool(^)(NSString *, NSUInteger)) checker;

/**
 @brief find next "
 */
-(NSUInteger) nextQuoteIndex:(NSUInteger) index;

/**
 @brief find next space index
 */
-(NSUInteger) nextSpaceIndex:(NSUInteger) index defaults:(NSUInteger) value;

/**
 @brief find next non space
 */
-(NSUInteger) nextNonSpaceIndex:(NSUInteger) index defaults:(NSUInteger) value;

/**
 @brief get next char (without empty char)
 */
-(unichar) nextChar:(NSUInteger) index defaults:(unichar) value;

/**
 @brief get last word
 */
-(NSString *) nextWord:(NSUInteger) index;

/**
 @brief find last index of string
 */
-(NSUInteger) lastIndex:(NSUInteger) index defaults:(NSUInteger) value compare: (bool(^)(NSString *, NSUInteger)) checker;

/**
 @brief find last space
 */
-(NSUInteger) lastSpaceIndex:(NSUInteger) index defaults:(NSUInteger) value;

/**
 @brief find last non space
 */
-(NSUInteger) lastNonSpaceIndex:(NSUInteger) index defaults:(NSUInteger) value;

/**
 @brief get last char (without empty char)
 */
-(unichar) lastChar:(NSUInteger) index defaults:(unichar) value;

/**
 @brief get last word
 */
-(NSString *) lastWord:(NSUInteger) index;


@end
