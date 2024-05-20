
build:
	nasm -Fdwarf -f elf64 entry.asm -o entry.o
	ld -T entry.ld -o entry.elf64 entry.o

clean:
	rm entry.elf64 entry.o
