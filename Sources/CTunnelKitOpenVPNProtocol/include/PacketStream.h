

#import <Foundation/Foundation.h>
#import "XORMethodNative.h"

NS_ASSUME_NONNULL_BEGIN

@interface PacketStream : NSObject

+ (NSArray<NSData *> *)packetsFromInboundStream:(NSData *)stream
                                          until:(NSInteger *)until
                                      xorMethod:(XORMethodNative)xorMethod
                                        xorMask:(nullable NSData *)xorMask;

+ (NSData *)outboundStreamFromPacket:(NSData *)packet
                           xorMethod:(XORMethodNative)xorMethod
                             xorMask:(nullable NSData *)xorMask;

+ (NSData *)outboundStreamFromPackets:(NSArray<NSData *> *)packets
                            xorMethod:(XORMethodNative)xorMethod
                              xorMask:(nullable NSData *)xorMask;

@end

NS_ASSUME_NONNULL_END
