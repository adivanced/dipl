[BITS 64]

global _start

section .data
	string db "smth", 0

section .text

	_start:
		mov rax, 0
		syscall
		nop
		nop
