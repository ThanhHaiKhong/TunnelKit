

#import <Foundation/Foundation.h>

#import "Crypto.h"
#import "DataPathCrypto.h"

NS_ASSUME_NONNULL_BEGIN

@interface CryptoAEAD : NSObject <Encrypter, Decrypter>

- (instancetype)initWithCipherName:(NSString *)cipherName;

@end

@interface DataPathCryptoAEAD : NSObject <DataPathEncrypter, DataPathDecrypter>

@property (nonatomic, assign) uint32_t peerId;

- (instancetype)initWithCrypto:(CryptoAEAD *)crypto;

@end

NS_ASSUME_NONNULL_END
