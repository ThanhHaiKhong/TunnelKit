

#import <Foundation/Foundation.h>

@import CTunnelKitOpenVPNCore;

NS_ASSUME_NONNULL_BEGIN

@protocol DataPathEncrypter;
@protocol DataPathDecrypter;

// send/receive should be mutually thread-safe

@interface DataPath : NSObject

@property (nonatomic, assign) uint32_t maxPacketId;

- (instancetype)initWithEncrypter:(id<DataPathEncrypter>)encrypter
                        decrypter:(id<DataPathDecrypter>)decrypter
                           peerId:(uint32_t)peerId // 24-bit, discard most significant byte
               compressionFraming:(CompressionFramingNative)compressionFraming
             compressionAlgorithm:(CompressionAlgorithmNative)compressionAlgorithm
                       maxPackets:(NSInteger)maxPackets
             usesReplayProtection:(BOOL)usesReplayProtection;

- (nullable NSArray<NSData *> *)encryptPackets:(NSArray<NSData *> *)packets key:(uint8_t)key error:(NSError **)error;
- (nullable NSArray<NSData *> *)decryptPackets:(NSArray<NSData *> *)packets keepAlive:(nullable bool *)keepAlive error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
