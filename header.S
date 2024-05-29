
#define MBOOT2_MAGIC 0x1BADB002
#define MBOOT2_ARCH 0
#define MBOOT2_LENGTH (Multiboot2HeaderEnd - Multiboot2Header)
#define MBOOT2_CHECKSUM -(MBOOT2_MAGIC + MBOOT2_ARCH)

.section .multiboot

.align 0x8
Multiboot2Header:
.long MBOOT2_MAGIC
.long MBOOT2_ARCH
.long MBOOT2_CHECKSUM

.short 0
.short 0
.long 8
Multiboot2HeaderEnd:

