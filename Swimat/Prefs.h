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

+(void) setAutoFormat:(bool) format;

+(bool) isAutoFormat;

+(void) setFormatOnBuild:(bool) format;

+(bool) isFormatOnBuild;

+(void) setIndentEmptyLine:(bool) format;

+(bool) isIndentEmptyLine;

@end
