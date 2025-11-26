#import <stddef.h>

void *allocate_safely(size_t size);

size_t safe_crypto_capacity(size_t size, size_t overhead);
