extern kernel_main

extern kernel_magic: dd

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

    push ebx
    push eax

		; call kernel_main
   call check_cpuid
   call check_extended_cpuid
   call check_long_mode

	cli
	loop:	hlt
		jmp loop

check_extended_cpuid:
  mov eax, 0x80000000
  CPUID
  cmp eax, 0x80000001
  jl  NoLongMode
  ret

check_long_mode:
  mov eax,  0x80000001
  CPUID
  and edx, 1 << 29
  cmp edx, 0
  jng NoLongMode
  ret

check_cpuid:
    ; Check if CPUID is supported by attempting to flip the ID bit (bit 21) in
    ; the FLAGS register. If we can flip it, CPUID is available.

    ; Copy FLAGS into EAX via stack
    pushfd
    pop eax

    ; Copy to ECX as well for comparing later on
    mov ecx, eax

    ; Flip the ID bit
    xor eax, 1 << 21

    ; Copy EAX to FLAGS via the stack
    push eax
    popfd

    ; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
    pushfd
    pop eax

    ; Restore FLAGS from the old version stored in ECX (i.e. flipping the ID bit
    ; back if it was ever flipped).
    push ecx
    popfd

    ; Compare EAX and ECX. If they are equal then that means the bit wasn't
    ; flipped, and CPUID isn't supported.
    cmp eax, ecx
    je NoLongMode
    ret

NoLongMode:
  jmp loop
