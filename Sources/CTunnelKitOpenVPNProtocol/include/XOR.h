
#import <Foundation/Foundation.h>
#import "XORMethodNative.h"

static inline void xor_mask(uint8_t *dst, const uint8_t *src, NSData *xorMask, size_t length)
{
    if (xorMask.length > 0) {
        for (size_t i = 0; i < length; ++i) {
            dst[i] = src[i] ^ ((uint8_t *)(xorMask.bytes))[i % xorMask.length];
        }
        return;
    }
    memcpy(dst, src, length);
}

static inline void xor_ptrpos(uint8_t *dst, const uint8_t *src, size_t length)
{
    for (size_t i = 0; i < length; ++i) {
        dst[i] = src[i] ^ (i + 1);
    }
}

static inline void xor_reverse(uint8_t *dst, const uint8_t *src, size_t length)
{
    size_t start = 1;
    size_t end = length - 1;
    uint8_t temp = 0;
    dst[0] = src[0];
    while (start < end) {
        temp = src[start];
        dst[start] = src[end];
        dst[end] = temp;
        start++;
        end--;
    }
    if (start == end) {
        dst[start] = src[start];
    }
}

static inline void xor_memcpy(uint8_t *dst, NSData *src, XORMethodNative method, NSData *mask, BOOL outbound)
{
    const uint8_t *source = (uint8_t *)src.bytes;
    switch (method) {
        case XORMethodNativeNone:
            memcpy(dst, source, src.length);
            break;

        case XORMethodNativeMask:
            xor_mask(dst, source, mask, src.length);
            break;

        case XORMethodNativePtrPos:
            xor_ptrpos(dst, source, src.length);
            break;

        case XORMethodNativeReverse:
            xor_reverse(dst, source, src.length);
            break;

        case XORMethodNativeObfuscate:
            if (outbound) {
                xor_ptrpos(dst, source, src.length);
                xor_reverse(dst, dst, src.length);
                xor_ptrpos(dst, dst, src.length);
                xor_mask(dst, dst, mask, src.length);
            } else {
                xor_mask(dst, source, mask, src.length);
                xor_ptrpos(dst, dst, src.length);
                xor_reverse(dst, dst, src.length);
                xor_ptrpos(dst, dst, src.length);
            }
            break;
    }
}
