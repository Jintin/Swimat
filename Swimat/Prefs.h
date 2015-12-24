//
//  Prefs.h
//  Swimat
//
//  Created by Jintin on 12/24/15.
//  Copyright © 2015 jintin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Prefs : NSObject

extern NSString * const TAG_INDENT;
extern NSString * const INDENT_TAB;
extern NSString * const INDENT_SPACE2;
extern NSString * const INDENT_SPACE4;

+(void) setIndent:(NSString *)value;

+(NSString *) getIndent;

+(NSArray *) getIndentArray;

+(NSString *) getIndentString;

@end
