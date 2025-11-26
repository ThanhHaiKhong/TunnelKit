
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZeroingData;
@protocol DataPathEncrypter;
@protocol DataPathDecrypter;

typedef struct {
    const uint8_t *_Nullable iv;
    NSInteger ivLength;
    const uint8_t *_Nullable ad;
    NSInteger adLength;
    BOOL forTesting;
} CryptoFlags;

// WARNING: dest must be able to hold ciphertext
@protocol Encrypter

- (void)configureEncryptionWithCipherKey:(nullable ZeroingData *)cipherKey hmacKey:(nullable ZeroingData *)hmacKey;
- (int)digestLength;
- (int)tagLength;

- (NSInteger)encryptionCapacityWithLength:(NSInteger)length;
- (BOOL)encryptBytes:(const uint8_t *)bytes length:(NSInteger)length dest:(uint8_t *)dest destLength:(NSInteger *)destLength flags:(const CryptoFlags *_Nullable)flags error:(NSError **)error;

- (id<DataPathEncrypter>)dataPathEncrypter;

@end

// WARNING: dest must be able to hold plaintext
@protocol Decrypter

- (void)configureDecryptionWithCipherKey:(nullable ZeroingData *)cipherKey hmacKey:(nullable ZeroingData *)hmacKey;
- (int)digestLength;
- (int)tagLength;

- (NSInteger)encryptionCapacityWithLength:(NSInteger)length;
- (BOOL)decryptBytes:(const uint8_t *)bytes length:(NSInteger)length dest:(uint8_t *)dest destLength:(NSInteger *)destLength flags:(const CryptoFlags *_Nullable)flags error:(NSError **)error;
- (BOOL)verifyBytes:(const uint8_t *)bytes length:(NSInteger)length flags:(const CryptoFlags *_Nullable)flags error:(NSError **)error;

- (id<DataPathDecrypter>)dataPathDecrypter;

@end

NS_ASSUME_NONNULL_END
