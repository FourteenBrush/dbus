#include <stdint.h>
#include <stdio.h>

typedef struct MemBlock MemBlock;

struct MemBlock {
    MemBlock *next;
    size_t used_so_far;
    unsigned char elements[];
};

typedef enum _WatchFlags {
    Readable = 1 << 0,
    Writable = 1 << 1,
    Error = 1 << 2,
    Hangup = 1 << 3,
} WatchFlags;

int main() {
    printf("%i\n", sizeof(WatchFlags));
}
