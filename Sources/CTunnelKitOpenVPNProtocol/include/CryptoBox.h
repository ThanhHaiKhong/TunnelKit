

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZeroingData;
@protocol Encrypter;
@protocol Decrypter;

@interface CryptoBox : NSObject

+ (NSString *)version;
+ (BOOL)preparePRNGWithSeed:(const uint8_t *)seed length:(NSInteger)length;

- (instancetype)initWithCipherAlgorithm:(nullable NSString *)cipherAlgorithm
                                digestAlgorithm:(nullable NSString *)digestAlgorithm;

- (BOOL)configureWithCipherEncKey:(nullable ZeroingData *)cipherEncKey
                     cipherDecKey:(nullable ZeroingData *)cipherDecKey
                       hmacEncKey:(nullable ZeroingData *)hmacEncKey
                       hmacDecKey:(nullable ZeroingData *)hmacDecKey
                            error:(NSError **)error;

// WARNING: hmac must be able to hold HMAC result
+ (BOOL)hmacWithDigestName:(NSString *)digestName
                    secret:(const uint8_t *)secret
              secretLength:(NSInteger)secretLength
                      data:(const uint8_t *)data
                dataLength:(NSInteger)dataLength
                      hmac:(uint8_t *)hmac
                hmacLength:(NSInteger *)hmacLength
                     error:(NSError **)error;


// encrypt/decrypt are mutually thread-safe
- (id<Encrypter>)encrypter;
- (id<Decrypter>)decrypter;

- (NSInteger)digestLength;
- (NSInteger)tagLength;

@end

NS_ASSUME_NONNULL_END
