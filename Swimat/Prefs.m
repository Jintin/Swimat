#import "Prefs.h"

@implementation Prefs

NSString * const TAG_AUTO_SAVE = @"auto_save";
NSString * const TAG_AUTO_ON_BUILD = @"auto_on_build";
NSString * const TAG_INDENT_EMPTY_LINE = @"IndentEmptyLine";
NSString * const TAG_INDENT = @"indent";
NSString * const INDENT_TAB = @"Tab Indent";
NSString * const INDENT_SPACE2 = @"2 Space Indent";
NSString * const INDENT_SPACE3 = @"3 Space Indent";
NSString * const INDENT_SPACE4 = @"4 Space Indent";

+(void) setIndent:(NSString *)value {
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   [prefs setObject:value forKey:TAG_INDENT];
   [prefs synchronize];
}

+(NSString *) getIndent {
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   NSString *value = [prefs stringForKey:TAG_INDENT];
   if (value == nil) {
      value = INDENT_TAB;
   }
   return value;
}

+(NSArray *) getIndentArray {
   return @[INDENT_TAB, INDENT_SPACE2, INDENT_SPACE3, INDENT_SPACE4];
}

+(NSString *) getIndentString {
   NSString *tag = [self getIndent];
   if ([tag isEqualToString:INDENT_TAB]) {
      return @"\t";
   } else if ([tag isEqualToString:INDENT_SPACE2]) {
      return @"  ";
   } else if ([tag isEqualToString:INDENT_SPACE3]) {
      return @"   ";
   } else if ([tag isEqualToString:INDENT_SPACE4]) {
      return @"    ";
   }
   return @"\t";
}

+(void) setAutoFormat:(bool) format {
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   [prefs setBool:format forKey:TAG_AUTO_SAVE];
   [prefs synchronize];
}

+(bool) isAutoFormat {
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   return [prefs boolForKey:TAG_AUTO_SAVE];
}

+(void) setFormatOnBuild:(bool) format {
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   [prefs setBool:format forKey:TAG_AUTO_ON_BUILD];
   [prefs synchronize];
}

+(bool) isFormatOnBuild {
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   return [prefs boolForKey:TAG_AUTO_ON_BUILD];
}

+(void) setIndentEmptyLine:(bool) format {
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   [prefs setBool:format forKey:TAG_INDENT_EMPTY_LINE];
   [prefs synchronize];
}

+(bool) isIndentEmptyLine {
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   return [prefs boolForKey:TAG_INDENT_EMPTY_LINE];
}


@end
