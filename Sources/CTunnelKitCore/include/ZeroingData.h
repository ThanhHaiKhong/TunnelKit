#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZeroingData : NSObject

@property (nonatomic, readonly) const uint8_t *bytes;
@property (nonatomic, readonly) uint8_t *mutableBytes;
@property (nonatomic, readonly) NSInteger count;

- (instancetype)initWithCount:(NSInteger)count;
- (instancetype)initWithBytes:(nullable const uint8_t *)bytes count:(NSInteger)count;
- (instancetype)initWithUInt8:(uint8_t)uint8;
- (instancetype)initWithUInt16:(uint16_t)uint16;

- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithData:(NSData *)data offset:(NSInteger)offset count:(NSInteger)count;
- (instancetype)initWithString:(NSString *)string nullTerminated:(BOOL)nullTerminated;

- (void)appendData:(ZeroingData *)other;
//- (void)truncateToSize:(NSInteger)size;
- (void)removeUntilOffset:(NSInteger)until;
- (void)zero;

- (ZeroingData *)appendingData:(ZeroingData *)other;
- (ZeroingData *)withOffset:(NSInteger)offset count:(NSInteger)count;
- (uint16_t)UInt16ValueFromOffset:(NSInteger)from;
- (uint16_t)networkUInt16ValueFromOffset:(NSInteger)from;
- (nullable NSString *)nullTerminatedStringFromOffset:(NSInteger)from;

- (BOOL)isEqualToData:(NSData *)data;
- (NSData *)toData; // XXX: unsafe
- (NSString *)toHex;

@end

NS_ASSUME_NONNULL_END
