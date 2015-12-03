#import <Foundation/Foundation.h>

@interface NSMutableString(Common)

/**
 @brief remove trailing space and add string with space
 */
-(void) spaceWith:(NSString *)string;

/**
 @brief keep one space at trailing
 */
-(void) keepSpace;

/**
 @brief remove trailing space
 */
-(void) trim;

@end
