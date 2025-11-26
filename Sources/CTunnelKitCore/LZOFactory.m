#import "LZOFactory.h"
#import "ZeroingData.h"

static NSString *const LZOClassName = @"StandardLZO";

static Class LZOClass()
{
    NSBundle *bundle = [NSBundle bundleForClass:[ZeroingData class]];
    return [bundle classNamed:LZOClassName];
}

@implementation LZOFactory

+ (BOOL)isSupported
{
    return LZOClass() != nil;
}

+ (id<CompressionProvider>)create
{
    return [[LZOClass() alloc] init];
}

@end
