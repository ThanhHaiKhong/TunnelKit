#import <Foundation/Foundation.h>
#import "CompressionProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface LZOFactory : NSObject

//+ (NSString *)versionString;
+ (BOOL)isSupported;
+ (id<CompressionProvider>)create;

@end

NS_ASSUME_NONNULL_END
