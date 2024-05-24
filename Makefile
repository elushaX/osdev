CROSS_PATH = ~/bin/core/cross/i686-elf/bin/

AS = nasm
CC = ~/bin/core/cross/bin/i686-elf-gcc
LD = ~/bin/core/cross/bin/i686-elf-ld

build:
	$(AS) -Fdwarf -f elf32 boot.asm -o boot.o
	$(CC) -c kernel.c -gdwarf -g -o kernel.o -std=gnu99 -ffreestanding -Wall -Wextra
	$(LD) -T linker.ld -o kernel.bin -nostdlib boot.o kernel.o

clean:
	rm *.o *.bini *.img
