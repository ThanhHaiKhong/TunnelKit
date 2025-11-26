

#import <Foundation/Foundation.h>

@interface ReplayProtector : NSObject

- (BOOL)isReplayedPacketId:(uint32_t)packetId;

@end
