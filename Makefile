CROSS_PATH = ~/bin/core/cross/i686-elf/bin/

build:
	gcc -gdwarf -g -c -x assembler-with-cpp boot.S -o boot.o -I.
	gcc -gdwarf -g -c -x assembler-with-cpp ./header.S -o header.o -I.
	gcc -gdwarf -g -c -x assembler-with-cpp ./page_table.S -o page_table.o -I.
	gcc -c kernel.c -gdwarf -g -o kernel.o -std=gnu99 -ffreestanding -Wall -Wextra
	gcc -c gdt.c -gdwarf -g -o gdt.o -std=gnu99 -ffreestanding -Wall -Wextra
	ld -T linker.ld -o kernel.bin -nostdlib boot.o kernel.o header.o page_table.o gdt.o

clean:
	rm *.o *.bini *.img
