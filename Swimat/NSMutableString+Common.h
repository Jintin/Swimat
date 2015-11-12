#import <Foundation/Foundation.h>

@interface NSMutableString(Common)

/**
 @brief remove trailing space and add string
 */
-(void) spaceWith:(NSString *)string;

/**
 @brief remove trailing space
 */
-(void) trim;

@end
