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
	resb 16384                           ; 16 KiB
stack_top:

section .text

global _start
_start:
	mov esp, stack_top

	push ebx
	push eax

	call check_cpuid
	call check_extended_cpuid
	call check_long_mode
	call setup_paging
	call jump_long

	cli
loop:
	hlt
	jmp loop

check_extended_cpuid:
	mov eax, 0x80000000
	CPUID
	cmp eax, 0x80000001
	jl NoLongMode
	ret

check_long_mode:
	mov eax, 0x80000001
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

setup_paging:
	; Set the destination index to 0x1000
	mov edi, 0x4000

	; Set control register 3 to the destination index
	mov ecx, edi
	mov cr3, ecx

; Nullify the A-register
	xor eax, eax

; Set the C-register to 4096
	mov ecx, 4096

; Clear the memory
	rep stosd

; Set the destination index to control register 3
	mov edi, cr3

	mov dword [edi], 0x5003              ; Set the uint32_t at the destination index to 0x2003.
	add edi, 0x1000                      ; Add 0x1000 to the destination index.
	mov dword [edi], 0x6003              ; Set the uint32_t at the destination index to 0x3003.
	add edi, 0x1000                      ; Add 0x1000 to the destination index.
	mov dword [edi], 0x7003              ; Set the uint32_t at the destination index to 0x4003.
	add edi, 0x1000                      ; Add 0x1000 to the destination index.

	mov ebx, 0x00000003                  ; Set the B-register to 0x00000003.
	mov ecx, 512                         ; Set the C-register to 512.

.SetEntry:
	mov dword [edi], ebx                 ; Set the uint32_t at the destination index to the B-register.
	add ebx, 0x1000                      ; Add 0x1000 to the B-register.
	add edi, 8                           ; Add eight to the destination index.
	loop .SetEntry                       ; Set the next entry.

	mov eax, cr4                         ; Move the value of control register 4 into EAX.
	or eax, 1 << 5                       ; Set the 6th bit (bit 5) in EAX.
	mov cr4, eax                         ; Move the modified value back to control register 4.

; enable long mode
	mov ecx, 0xC0000080                  ; Set the C-register to 0xC0000080, which is the EFER MSR.
	rdmsr                                ; Read from the model-specific register.
	or eax, 1 << 8                       ; Set the LM-bit which is the 9th bit (bit 8).
	wrmsr                                ; Write to the model-specific register.

; enable paging
	mov eax, cr0                         ; Set the A-register to control register 0.
	or eax, 1 << 31                      ; Set the PG-bit, which is the 32nd bit (bit 31).
	mov cr0, eax                         ; Set control register 0 to the A-register.

	ret


; Access bits
%define PRESENT        (1 << 7)
%define NOT_SYS        (1 << 4)
%define EXEC           (1 << 3)
%define DC             (1 << 2)
%define RW             (1 << 1)
%define ACCESSED       (1 << 0)

; Flags bits
%define GRAN_4K       (1 << 7)
%define SZ_32         (1 << 6)
%define LONG_MODE     (1 << 5)

GDT:
	Null        equ $ - GDT
		dq      0
	Code        equ $ - GDT
		dd      0xFFFF                                   ; Limit & Base (low, bits 0-15)
		db      0                                        ; Base (mid, bits 16-23)
		db      PRESENT | NOT_SYS | EXEC | RW            ; Access
		db      GRAN_4K | LONG_MODE | 0xF                ; Flags & Limit (high, bits 16-19)
		db      0                                        ; Base (high, bits 24-31)
	Data        equ $ - GDT
		dd      0xFFFF                                   ; Limit & Base (low, bits 0-15)
		db      0                                        ; Base (mid, bits 16-23)
		db      PRESENT | NOT_SYS | RW                   ; Access
		db      GRAN_4K | SZ_32 | 0xF                    ; Flags & Limit (high, bits 16-19)
		db      0                                        ; Base (high, bits 24-31)
	TSS         equ $ - GDT
		dd      0x00000068
		dd      0x00CF8900
	.Pointer:
		dw          $ - GDT - 1
		dq          GDT

jump_long:
	lgdt [GDT.Pointer]
