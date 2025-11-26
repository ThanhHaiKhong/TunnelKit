
#import <Foundation/Foundation.h>

#define TUNNEL_CRYPTO_SUCCESS(ret) (ret > 0)
#define TUNNEL_CRYPTO_TRACK_STATUS(ret) if (ret > 0) ret =
#define TUNNEL_CRYPTO_RETURN_STATUS(ret)\
if (ret <= 0) {\
    if (error) {\
        *error = OpenVPNErrorWithCode(OpenVPNErrorCodeCryptoEncryption);\
    }\
    return NO;\
}\
return YES;
