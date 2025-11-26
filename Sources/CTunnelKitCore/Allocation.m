#import <stdlib.h>
#import <Foundation/Foundation.h>

#import "Allocation.h"

#define MAX_BLOCK_SIZE  16  // AES only, block is 128-bit

void *allocate_safely(size_t size) {
    void *memory = malloc(size);
    if (!memory) {
        NSLog(@"malloc() call failed");
        abort();
        return NULL;
    }
    return memory;
}

size_t safe_crypto_capacity(size_t size, size_t overhead) {

    // encryption, byte-alignment, overhead (e.g. IV, digest)
    return 2 * size + MAX_BLOCK_SIZE + overhead;
}
