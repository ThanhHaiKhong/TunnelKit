

#import <Foundation/Foundation.h>

#import "Crypto.h"
#import "DataPathCrypto.h"

NS_ASSUME_NONNULL_BEGIN

@interface CryptoCBC : NSObject <Encrypter, Decrypter>

- (instancetype)initWithCipherName:(nullable NSString *)cipherName digestName:(NSString *)digestName;

@end

@interface DataPathCryptoCBC : NSObject <DataPathEncrypter, DataPathDecrypter>

@property (nonatomic, assign) uint32_t peerId;

- (instancetype)initWithCrypto:(CryptoCBC *)crypto;

@end

NS_ASSUME_NONNULL_END
