extern kernel_main

section .multiboot
	align 4
	magic equ 0x1BADB002
	flags equ (1<<0) | (1<<1)
	checksum equ - (magic + flags)
	multiboot_header:
		dd magic
		dd flags
		dd checksum

section .bss
	align 16
	stack_bottom:
		resb 16384   ; 16 KiB
	stack_top:

section .text
	global _start
	_start:
		mov esp, stack_top

		; Kernel initialization code goes here

		call kernel_main

		cli
	loop:	hlt
		jmp loop

