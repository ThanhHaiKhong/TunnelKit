
#import <Foundation/Foundation.h>

#import "Crypto.h"
#import "DataPathCrypto.h"

NS_ASSUME_NONNULL_BEGIN

@interface CryptoCTR : NSObject <Encrypter, Decrypter>

- (instancetype)initWithCipherName:(nullable NSString *)cipherName digestName:(NSString *)digestName;

@end

NS_ASSUME_NONNULL_END
