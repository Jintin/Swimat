#import <Foundation/Foundation.h>

@interface Prefs : NSObject

extern NSString * const TAG_INDENT;
extern NSString * const INDENT_TAB;
extern NSString * const INDENT_SPACE2;
extern NSString * const INDENT_SPACE4;

/**
 *  Different values for the "break before opening brace" rule. For clarity: this rule only affects '{' ("brace").
 */
typedef NS_ENUM(NSInteger, SWMBreakBeforeOpeningBraceRule) {
    /**
     *  Default rule.
     */
    SWMBreakBeforeOpeningBraceRuleIgnore = 0,
    /**
     *  Removes all newlines before opening braces.
     */
    SWMBreakBeforeOpeningBraceRuleRemove,
    /**
     *  Removes and inserts newlines before opening braces so that in the formatted output there is one newline before each opening brace.
     */
    SWMBreakBeforeOpeningBraceRuleForce,
};

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

+ (void)setBreakBeforeOpeningBraceRule:(SWMBreakBeforeOpeningBraceRule)rule;
+ (SWMBreakBeforeOpeningBraceRule)breakBeforeOpeningBraceRule;

+ (NSString *)enabledBreakBeforeOpeningBraceRuleMenuItemTitle;
+ (NSString *)menuItemTitleForBreakBeforeOpeningBraceRule:(SWMBreakBeforeOpeningBraceRule)rule;

@end
