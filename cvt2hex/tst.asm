[BITS 64]
[DEFAULT REL]

global _start

section .text
_start:

	xor rax, rax
	mov ax, __utf16__(`5`)
	mov rbx, 5
	mov bx, word [jtbl+rbx*2]
	lea rdi, [tst]
	stosw
	mov bx, word [tst]

	nop
	nop

	jtbl dw __utf16__(`0123456789ABCDEF\0`) 



section .data
	tst1 dw __utf16__(`5`)
	tst dw 0