symbol-file kernel.bin
set arch i386:x86-64
target remote :1234
hbreak _start
hbreak kernel_main

set disassemble-next-line on

continue

