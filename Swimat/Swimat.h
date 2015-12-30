#import <AppKit/AppKit.h>

@class Swimat;

static Swimat *sharedPlugin;

@interface Swimat : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;

- (void) format;

- (NSRange) findDiffRange:(NSString *) string1 string2:(NSString *) string2;

@end