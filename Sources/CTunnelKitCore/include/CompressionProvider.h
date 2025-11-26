#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CompressionProvider

- (nullable NSData *)compressedDataWithData:(NSData *)data error:(NSError **)error;
- (nullable NSData *)decompressedDataWithData:(NSData *)data error:(NSError **)error;
- (nullable NSData *)decompressedDataWithBytes:(const uint8_t *)bytes length:(NSInteger)length error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
