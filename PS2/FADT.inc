[BITS 64]
[DEFAULT REL]

; no args, need global variable XSDT
get_FADT_BAR:
	mov rdi, qword [XSDT]
	mov edx, dword [rdi+4] ; XSDT size
	sub edx, 36
	shr edx, 3
	add rdi, 36

	mov ecx, 'FACP'
	xor rax, rax
	.findloop_FADT:
		mov rsi, qword [rdi+rax*8]
		cmp ecx, dword [rsi]
		jz .equal_FADT
		inc rax
		cmp rax, rdx
	jnz .findloop_FADT

	mov rax, -1
ret
.equal_FADT:
	mov qword [FADT], rsi
	xor rax, rax
ret
