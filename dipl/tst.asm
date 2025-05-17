[default REL]
[BITS 64]

global _start

section .data
	arr dq 4, 5, 16, 9, 11
	times 50000 dq 0

section .text
	_start:
		lea rdi, [arr]
		mov rsi, 50000
		call bench_start

		nop
		nop

		mov rax, qword [arr]
		mov rbx, qword [arr+8]
		mov rcx, qword [arr+16]
		mov rdx, qword [arr+24]
		mov rbp, qword [arr+32]


		mov rax, 60
		xor rdi, rdi
		syscall


	bench_start:
	incbin "code.o"
; push   rbp
; mov    rbp,rsp
; mov    QWORD [rbp-0x18],rdi
; mov    QWORD [rbp-0x20],rsi
; mov    QWORD [rbp-0x10],0x0
; jmp    L2 ; L2
; L6:
; mov    rax,QWORD [rbp-0x10]
; lea    rdx,[rax*8+0x0]
; mov    rax,QWORD [rbp-0x18]
; add    rax,rdx
; mov    rdx,QWORD [rax]
; mov    rax,QWORD [rbp-0x10]
; lea    rcx,[rax*8+0x0]

; mov    rax,QWORD [rbp-0x18]
; add    rax,rcx
; mov    rax,QWORD [rax]
; imul   rax,rdx
; mov    rdx,QWORD [rbp-0x10]
; lea    rcx,[rdx*8+0x0]

; mov    rdx,QWORD [rbp-0x18]
; add    rcx,rdx
; shr    rax,0x2
; mov rdx,0x28f5c28f5c28f5c3
; mul    rdx
; mov    rax,rdx
; shr    rax,0x2
; mov    QWORD [rcx],rax
; mov    rax,QWORD [rbp-0x10]
; add    rax,0x1
; cmp    QWORD [rbp-0x20],rax
; jbe    L3
; mov    rax,QWORD [rbp-0x10]
; lea    rdx,[rax*8+0x0]
; mov    rax,QWORD [rbp-0x18]
; add    rax,rdx
; mov    rcx,QWORD [rax]
; mov    rax,QWORD [rbp-0x10]
; add    rax,0x1
; lea    rdx,[rax*8+0x0]
; mov    rax,QWORD [rbp-0x18]
; add    rax,rdx
; mov    rax,QWORD [rax]
; mov    rdx,QWORD [rbp-0x10]
; lea    rsi,[rdx*8+0x0]
; mov    rdx,QWORD [rbp-0x18]
; add    rdx,rsi
; imul   rax,rcx
; mov    QWORD [rdx],rax
; L3:
; mov    rax,QWORD [rbp-0x10]
; lea    rdx,[rax*8+0x0]
; mov    rax,QWORD [rbp-0x18]
; add    rax,rdx
; mov    rax,QWORD [rax]
; mov    rdx,QWORD [rbp-0x10]
; shl    rdx,0x3
; lea    rcx,[rdx-0x8]
; mov    rdx,QWORD [rbp-0x18]
; add    rdx,rcx
; mov    rdx,QWORD [rdx]
; lea    rsi,[rdx+0x1]
; mov    rdx,QWORD [rbp-0x10]
; lea    rcx,[rdx*8+0x0]
; mov    rdx,QWORD [rbp-0x18]
; add    rcx,rdx
; mov    edx,0x0
; div    rsi
; mov    QWORD [rcx],rax
; mov    rax,QWORD [rbp-0x10]
; add    rax,0x1
; mov    QWORD [rbp-0x8],rax
; jmp    L4
; L5:
; mov    rax,QWORD [rbp-0x10]
; lea    rdx,[rax*8+0x0]
; mov    rax,QWORD [rbp-0x18]
; add    rax,rdx
; mov    rcx,QWORD [rax]
; mov    rax,QWORD [rbp-0x8]
; lea    rdx,[rax*8+0x0]
; mov    rax,QWORD [rbp-0x18]
; add    rax,rdx
; mov    rdx,QWORD [rax]
; mov    rax,QWORD [rbp-0x10]
; lea    rsi,[rax*8+0x0]
; mov    rax,QWORD [rbp-0x18]
; add    rax,rsi
; add    rdx,rcx
; mov    QWORD [rax],rdx
; add    QWORD [rbp-0x8],0x1
; L4:
; mov    rax,QWORD [rbp-0x8]
; cmp    rax,QWORD [rbp-0x20]
; jb     L5
; add    QWORD [rbp-0x10],0x1
; L2:  
; mov    rax,QWORD [rbp-0x10]
; cmp    rax,QWORD [rbp-0x20]
; jb     L6 ; L6
; nop
; nop
; pop    rbp
; ret 