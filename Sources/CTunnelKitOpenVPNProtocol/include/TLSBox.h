
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern const NSInteger TLSBoxMaxBufferLength;

extern NSString *const TLSBoxPeerVerificationErrorNotification;

extern const NSInteger TLSBoxDefaultSecurityLevel;

//
// cipher text is safe within NSData
// plain text might be sensitive and must avoid NSData
//
// WARNING: not thread-safe!
//
@interface TLSBox : NSObject

@property (nonatomic, assign) NSInteger securityLevel; // TLSBoxDefaultSecurityLevel for default

+ (nullable NSString *)md5ForCertificatePath:(NSString *)path error:(NSError **)error;
+ (nullable NSString *)decryptedPrivateKeyFromPath:(NSString *)path passphrase:(NSString *)passphrase error:(NSError **)error;
+ (nullable NSString *)decryptedPrivateKeyFromPEM:(NSString *)pem passphrase:(NSString *)passphrase error:(NSError **)error;

- (instancetype)initWithCAPath:(nonnull NSString *)caPath
             clientCertificate:(nullable NSString *)clientCertificatePEM
                     clientKey:(nullable NSString *)clientKeyPEM
                     checksEKU:(BOOL)checksEKU
                 checksSANHost:(BOOL)checksSANHost
                      hostname:(nullable NSString *)hostname;

- (BOOL)startWithError:(NSError **)error;

- (nullable NSData *)pullCipherTextWithError:(NSError **)error;
// WARNING: text must be able to hold plain text output
- (BOOL)pullRawPlainText:(uint8_t *)text length:(NSInteger *)length error:(NSError **)error;

- (BOOL)putCipherText:(NSData *)text error:(NSError **)error;
- (BOOL)putRawCipherText:(const uint8_t *)text length:(NSInteger)length error:(NSError **)error;
- (BOOL)putPlainText:(NSString *)text error:(NSError **)error;
- (BOOL)putRawPlainText:(const uint8_t *)text length:(NSInteger)length error:(NSError **)error;

- (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END
