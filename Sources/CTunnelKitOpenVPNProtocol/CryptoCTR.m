
#import <openssl/evp.h>
#import <openssl/hmac.h>

#import "CryptoCTR.h"
#import "CryptoMacros.h"
#import "PacketMacros.h"
#import "ZeroingData.h"
#import "Allocation.h"
#import "Errors.h"

static const NSInteger CryptoCTRTagLength = 32;

@interface CryptoCTR ()

@property (nonatomic, unsafe_unretained) const EVP_CIPHER *cipher;
@property (nonatomic, unsafe_unretained) const EVP_MD *digest;
@property (nonatomic, unsafe_unretained) char *utfCipherName;
@property (nonatomic, unsafe_unretained) char *utfDigestName;
@property (nonatomic, assign) int cipherKeyLength;
@property (nonatomic, assign) int cipherIVLength;
@property (nonatomic, assign) int hmacKeyLength;

@property (nonatomic, unsafe_unretained) EVP_CIPHER_CTX *cipherCtxEnc;
@property (nonatomic, unsafe_unretained) EVP_CIPHER_CTX *cipherCtxDec;
@property (nonatomic, strong) ZeroingData *hmacKeyEnc;
@property (nonatomic, strong) ZeroingData *hmacKeyDec;
@property (nonatomic, unsafe_unretained) uint8_t *bufferDecHMAC;

@end

@implementation CryptoCTR

- (instancetype)initWithCipherName:(NSString *)cipherName digestName:(NSString *)digestName
{
    NSParameterAssert(cipherName && [[cipherName uppercaseString] hasSuffix:@"CTR"]);
    NSParameterAssert(digestName);
    
    self = [super init];
    if (self) {
        self.utfCipherName = calloc([cipherName length] + 1, sizeof(char));
        strncpy(self.utfCipherName, [cipherName UTF8String], [cipherName length]);
        self.cipher = EVP_get_cipherbyname(self.utfCipherName);
        NSAssert(self.cipher, @"Unknown cipher '%@'", cipherName);

        self.utfDigestName = calloc([digestName length] + 1, sizeof(char));
        strncpy(self.utfDigestName, [digestName UTF8String], [digestName length]);
        self.digest = EVP_get_digestbyname(self.utfDigestName);
        NSAssert(self.digest, @"Unknown digest '%@'", digestName);
        
        self.cipherKeyLength = EVP_CIPHER_key_length(self.cipher);
        self.cipherIVLength = EVP_CIPHER_iv_length(self.cipher);
        // as seen in OpenVPN's crypto_openssl.c:md_kt_size()
        self.hmacKeyLength = (int)EVP_MD_size(self.digest);
        NSAssert(EVP_MD_size(self.digest) == CryptoCTRTagLength, @"Expected digest size to be tag length (%ld)", CryptoCTRTagLength);
        
        self.cipherCtxEnc = EVP_CIPHER_CTX_new();
        self.cipherCtxDec = EVP_CIPHER_CTX_new();

        self.bufferDecHMAC = allocate_safely(CryptoCTRTagLength);
    }
    return self;
}

- (void)dealloc
{
    EVP_CIPHER_CTX_free(self.cipherCtxEnc);
    EVP_CIPHER_CTX_free(self.cipherCtxDec);
    bzero(self.bufferDecHMAC, CryptoCTRTagLength);
    free(self.bufferDecHMAC);

    free(self.utfCipherName);
    free(self.utfDigestName);

    self.cipher = NULL;
    self.digest = NULL;
}

- (int)digestLength
{
    return CryptoCTRTagLength;
}

- (int)tagLength
{
    return CryptoCTRTagLength;
}

- (NSInteger)encryptionCapacityWithLength:(NSInteger)length
{
    return safe_crypto_capacity(length, PacketOpcodeLength + PacketSessionIdLength + PacketReplayIdLength + PacketReplayTimestampLength + CryptoCTRTagLength);
}

#pragma mark Encrypter

- (void)configureEncryptionWithCipherKey:(ZeroingData *)cipherKey hmacKey:(ZeroingData *)hmacKey
{
    NSParameterAssert(hmacKey);
    NSParameterAssert(hmacKey.count >= self.hmacKeyLength);
    NSParameterAssert(cipherKey.count >= self.cipherKeyLength);
    
    EVP_CIPHER_CTX_reset(self.cipherCtxEnc);
    EVP_CipherInit(self.cipherCtxEnc, self.cipher, cipherKey.bytes, NULL, 1);
    
    self.hmacKeyEnc = [[ZeroingData alloc] initWithBytes:hmacKey.bytes count:self.hmacKeyLength];
}

- (BOOL)encryptBytes:(const uint8_t *)bytes length:(NSInteger)length dest:(uint8_t *)dest destLength:(NSInteger *)destLength flags:(const CryptoFlags * _Nullable)flags error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSParameterAssert(flags);

    uint8_t *outEncrypted = dest + CryptoCTRTagLength;
    int l1 = 0, l2 = 0;
    size_t l3 = 0;
    int code = 1;
    
    HMAC_CTX *ctx = HMAC_CTX_new();
    TUNNEL_CRYPTO_TRACK_STATUS(code) HMAC_Init_ex(ctx, self.hmacKeyEnc.bytes, (int)self.hmacKeyEnc.count, self.digest, NULL);
    TUNNEL_CRYPTO_TRACK_STATUS(code) HMAC_Update(ctx, flags->ad, flags->adLength);
    TUNNEL_CRYPTO_TRACK_STATUS(code) HMAC_Update(ctx, bytes, length);
    TUNNEL_CRYPTO_TRACK_STATUS(code) HMAC_Final(ctx, dest, (unsigned int *)&l3);
    HMAC_CTX_free(ctx);

    NSAssert(l3 == CryptoCTRTagLength, @"Incorrect digest size");
    
    TUNNEL_CRYPTO_TRACK_STATUS(code) EVP_CipherInit(self.cipherCtxEnc, NULL, NULL, dest, -1);
    TUNNEL_CRYPTO_TRACK_STATUS(code) EVP_CipherUpdate(self.cipherCtxEnc, outEncrypted, &l1, bytes, (int)length);
    TUNNEL_CRYPTO_TRACK_STATUS(code) EVP_CipherFinal_ex(self.cipherCtxEnc, outEncrypted + l1, &l2);
    
    *destLength = CryptoCTRTagLength + l1 + l2;
    
    TUNNEL_CRYPTO_RETURN_STATUS(code)
}

- (id<DataPathEncrypter>)dataPathEncrypter
{
    [NSException raise:NSInvalidArgumentException format:@"DataPathEncryption not supported"];
    return nil;
}

#pragma mark Decrypter

- (void)configureDecryptionWithCipherKey:(ZeroingData *)cipherKey hmacKey:(ZeroingData *)hmacKey
{
    NSParameterAssert(hmacKey);
    NSParameterAssert(hmacKey.count >= self.hmacKeyLength);
    NSParameterAssert(cipherKey.count >= self.cipherKeyLength);
    
    EVP_CIPHER_CTX_reset(self.cipherCtxDec);
    EVP_CipherInit(self.cipherCtxDec, self.cipher, cipherKey.bytes, NULL, 0);
    
    self.hmacKeyDec = [[ZeroingData alloc] initWithBytes:hmacKey.bytes count:self.hmacKeyLength];
}

- (BOOL)decryptBytes:(const uint8_t *)bytes length:(NSInteger)length dest:(uint8_t *)dest destLength:(NSInteger *)destLength flags:(const CryptoFlags * _Nullable)flags error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    NSParameterAssert(flags);
    NSAssert(self.cipher, @"No cipher provided");

    const uint8_t *iv = bytes;
    const uint8_t *encrypted = bytes + CryptoCTRTagLength;
    int l1 = 0, l2 = 0;
    size_t l3 = 0;
    int code = 1;

    TUNNEL_CRYPTO_TRACK_STATUS(code) EVP_CipherInit(self.cipherCtxDec, NULL, NULL, iv, -1);
    TUNNEL_CRYPTO_TRACK_STATUS(code) EVP_CipherUpdate(self.cipherCtxDec, dest, &l1, encrypted, (int)length - CryptoCTRTagLength);
    TUNNEL_CRYPTO_TRACK_STATUS(code) EVP_CipherFinal_ex(self.cipherCtxDec, dest + l1, &l2);

    *destLength = l1 + l2;
    
    HMAC_CTX *ctx = HMAC_CTX_new();
    TUNNEL_CRYPTO_TRACK_STATUS(code) HMAC_Init_ex(ctx, self.hmacKeyDec.bytes, (int)self.hmacKeyDec.count, self.digest, NULL);
    TUNNEL_CRYPTO_TRACK_STATUS(code) HMAC_Update(ctx, flags->ad, flags->adLength);
    TUNNEL_CRYPTO_TRACK_STATUS(code) HMAC_Update(ctx, dest, *destLength);
    TUNNEL_CRYPTO_TRACK_STATUS(code) HMAC_Final(ctx, self.bufferDecHMAC, (unsigned int *)&l3);
    HMAC_CTX_free(ctx);

    NSAssert(l3 == CryptoCTRTagLength, @"Incorrect digest size");
    
    if (TUNNEL_CRYPTO_SUCCESS(code) && CRYPTO_memcmp(self.bufferDecHMAC, bytes, CryptoCTRTagLength) != 0) {
        if (error) {
            *error = OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoHMAC);
        }
        return NO;
    }
    
    TUNNEL_CRYPTO_RETURN_STATUS(code)
}

- (BOOL)verifyBytes:(const uint8_t *)bytes length:(NSInteger)length flags:(const CryptoFlags * _Nullable)flags error:(NSError * _Nullable __autoreleasing * _Nullable)error
{
    [NSException raise:NSInvalidArgumentException format:@"Verification not supported"];
    return NO;
}

- (id<DataPathDecrypter>)dataPathDecrypter
{
    [NSException raise:NSInvalidArgumentException format:@"DataPathEncryption not supported"];
    return nil;
}

@end
