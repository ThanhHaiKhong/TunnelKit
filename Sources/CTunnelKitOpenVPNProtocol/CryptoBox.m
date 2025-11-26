

#import <openssl/evp.h>
#import <openssl/hmac.h>
#import <openssl/rand.h>

#import "CryptoBox.h"
#import "CryptoMacros.h"
#import "Allocation.h"
#import "Errors.h"

#import "CryptoCBC.h"
#import "CryptoAEAD.h"
#import "CryptoCTR.h"

@interface CryptoBox ()

@property (nonatomic, strong) NSString *cipherAlgorithm;
@property (nonatomic, strong) NSString *digestAlgorithm;
@property (nonatomic, assign) NSInteger digestLength;
@property (nonatomic, assign) NSInteger tagLength;

@property (nonatomic, strong) id<Encrypter> encrypter;
@property (nonatomic, strong) id<Decrypter> decrypter;

@end

@implementation CryptoBox

+ (void)initialize
{
}

+ (NSString *)version
{
    return [NSString stringWithCString:OpenSSL_version(OPENSSL_VERSION) encoding:NSASCIIStringEncoding];
}

+ (BOOL)preparePRNGWithSeed:(const uint8_t *)seed length:(NSInteger)length
{
    unsigned char x[1];
    // make sure its initialized before seeding
    if (RAND_bytes(x, 1) != 1) {
        return NO;
    }
    RAND_seed(seed, (int)length);
    return YES;
}

- (instancetype)initWithCipherAlgorithm:(NSString *)cipherAlgorithm digestAlgorithm:(NSString *)digestAlgorithm
{
    NSParameterAssert(cipherAlgorithm || digestAlgorithm);
    
    if ((self = [super init])) {
        self.cipherAlgorithm = [cipherAlgorithm lowercaseString];
        self.digestAlgorithm = [digestAlgorithm lowercaseString];
    }
    return self;
}

- (void)dealloc
{
    self.encrypter = nil;
    self.decrypter = nil;
}

// these keys are coming from the OpenVPN negotiation despite the cipher
- (BOOL)configureWithCipherEncKey:(ZeroingData *)cipherEncKey
                     cipherDecKey:(ZeroingData *)cipherDecKey
                       hmacEncKey:(ZeroingData *)hmacEncKey
                       hmacDecKey:(ZeroingData *)hmacDecKey
                            error:(NSError *__autoreleasing *)error
{
    NSParameterAssert((cipherEncKey && cipherDecKey) || (hmacEncKey && hmacDecKey));

    if (self.cipherAlgorithm) {
        if ([self.cipherAlgorithm hasSuffix:@"-cbc"]) {
            if (!self.digestAlgorithm) {
                if (error) {
                    *error = OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoAlgorithm);
                }
                return NO;
            }
            CryptoCBC *cbc = [[CryptoCBC alloc] initWithCipherName:self.cipherAlgorithm digestName:self.digestAlgorithm];
            self.encrypter = cbc;
            self.decrypter = cbc;
        }
        else if ([self.cipherAlgorithm hasSuffix:@"-gcm"]) {
            CryptoAEAD *gcm = [[CryptoAEAD alloc] initWithCipherName:self.cipherAlgorithm];
            self.encrypter = gcm;
            self.decrypter = gcm;
        }
        else if ([self.cipherAlgorithm hasSuffix:@"-ctr"]) {
            CryptoCTR *ctr = [[CryptoCTR alloc] initWithCipherName:self.cipherAlgorithm digestName:self.digestAlgorithm];
            self.encrypter = ctr;
            self.decrypter = ctr;
        }
        // not supported
        else {
            if (error) {
                *error = OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoAlgorithm);
            }
            return NO;
        }
    }
    else {
        CryptoCBC *cbc = [[CryptoCBC alloc] initWithCipherName:nil digestName:self.digestAlgorithm];
        self.encrypter = cbc;
        self.decrypter = cbc;
    }
    
    [self.encrypter configureEncryptionWithCipherKey:cipherEncKey hmacKey:hmacEncKey];
    [self.decrypter configureDecryptionWithCipherKey:cipherDecKey hmacKey:hmacDecKey];

    NSAssert(self.encrypter.digestLength == self.decrypter.digestLength, @"Digest length mismatch in encrypter/decrypter");
    self.digestLength = self.encrypter.digestLength;
    self.tagLength = self.encrypter.tagLength;

    return YES;
}

+ (BOOL)hmacWithDigestName:(NSString *)digestName
                    secret:(const uint8_t *)secret
              secretLength:(NSInteger)secretLength
                      data:(const uint8_t *)data
                dataLength:(NSInteger)dataLength
                      hmac:(uint8_t *)hmac
                hmacLength:(NSInteger *)hmacLength
                     error:(NSError **)error
{
    NSParameterAssert(digestName);
    NSParameterAssert(secret);
    NSParameterAssert(data);
    
    unsigned int l = 0;

    const BOOL success = HMAC(EVP_get_digestbyname([digestName cStringUsingEncoding:NSASCIIStringEncoding]),
                              secret,
                              (int)secretLength,
                              data,
                              dataLength,
                              hmac,
                              &l) != NULL;

    *hmacLength = l;

    return success;
}

@end
