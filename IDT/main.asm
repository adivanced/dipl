[BITS 64]
[DEFAULT REL]

%include "../jd9999_hdr_macro.inc"
jd9999_hdr_macro textsize, datasize, 0x0, textsize+datasize+1024

%macro print 1
	mov rcx, qword [EFI_SYSTEM_TABLE]
	mov rcx, qword [rcx+64]
	lea rdx, [%1]
	call [efi_print]
%endmacro

%macro getch 1
	mov rcx, qword [EFI_SYSTEM_TABLE]
	mov rcx, qword [rcx+48]
	lea rdx, [%1]
	call [efi_getch]
%endmacro


section .text follows=.header
start:
	sub rsp, 6*8+8 ; Copied from Charles AP's implementation, fix stack alignment issue (Thanks Charles AP!)

	cli

	mov qword [EFI_HANDLE], rcx
	mov qword [EFI_SYSTEM_TABLE], rdx

	mov rax, qword [EFI_SYSTEM_TABLE]
	mov rax, qword [rax+64]
	mov rax, qword [rax+8]
	mov qword [efi_print], rax

	mov rax, qword [EFI_SYSTEM_TABLE]
	mov rax, qword [rax+48]
	mov rax, qword [rax+8]
	mov qword [efi_getch], rax



	sidt [IDTR2]

	xor rax, rax
	mov rax, qword [IDTR2.base]
	lea rdi, [tststr+17*2]
	call cvt2hex
	print tststr

	mov ax, word [IDTR2.limit]
	inc ax
	lea rdi, [tststr+17*2]
	call cvt2hex
	print tststr


	mov rax, 5
	mov dl, 0xFE
	mov dh, 0xBA
	mov rcx, qword [sampleaddr]
	mov rbx, 0x0c00
	call write_IDT_gate


	;cli 
	;hlt
	xor r14w, r14w ; counter
	xor r13, r13
	mov r13w, word [IDTR2.limit]
	;inc r13w
	shr r13, 4
	jmp printall
	_loop:
		getch key
		test rax, rax
		jz gotkey
	jmp _loop

	gotkey:
		cmp word [key.char], __utf16__(`a`)
		jz back
		cmp word [key.char], __utf16__(`d`)
		jz fwd
	jmp _loop

	back:
		;cmp r14w, 0
		test r14w, r14w
		jz _loop
		dec r14w
	jmp printall

	fwd:
		cmp r14w, r13w
		jae _loop
		inc r14w
	jmp printall

	printall:
		xor rax, rax
		mov ax, r14w
		call read_IDT_gate

		push rcx
		push rdx
		push rbx				
		push rax
;0x07478E0000381018
;addr 0x0747
;flgs 0x8E00
;selc 0x0038
;addr 0x1018  
		print divstr

		pop rax

		lea rdi, [idstr+27*2]
		call cvt2hex

		print idstr

		pop rax

		lea rdi, [selstr+27*2]
		call cvt2hex

		print selstr

		mov rax, qword [rsp]

		xor ah, ah
		lea rdi, [iststr+27*2]
		call cvt2hex

		print iststr

		pop rax

		;and rax, 0xFF00
		mov al, ah
		xor ah, ah
		;shr rax, 8
		lea rdi, [typestr+27*2]
		call cvt2hex

		print typestr

		pop rax 

		lea rdi, [ptrstr+27*2]
		call cvt2hex

		print ptrstr

	jmp _loop



	; mov r12, qword [IDTR2.base]
	; xor r13, r13
	; mov r13w, word [IDTR2.limit]
	; ;inc r13w
	; shr r13, 4
	; xor r14, r14

	; _loop:
	; 	getch key
	; 	test rax, rax
	; 	jz gotkey
	; jmp _loop

	; gotkey:
	; 	cmp word [key.char], __utf16__(`a`)
	; 	jz back
	; 	cmp word [key.char], __utf16__(`d`)
	; 	jz fwd
	; jmp _loop

	; back:
	; 	cmp r14, 0
	; 	jz _loop
	; 	sub r12, 16
	; 	dec r14

	; 	mov rax, r14
	; 	lea rdi, [idstr+25*2]
	; 	call cvt2hex
	; 	print idstr

	; 	mov rax, qword [r12]
	; 	lea rdi, [tststr+17*2]
	; 	call cvt2hex
	; 	print tststr		

	; 	mov rax, qword [r12+8]
	; 	lea rdi, [tststr+17*2]
	; 	call cvt2hex
	; 	print tststr		
	; jmp _loop

	; fwd:
	; 	cmp r14, r13
	; 	jae _loop
	; 	add r12, 16
	; 	inc r14

	; 	mov rax, r14
	; 	lea rdi, [idstr+25*2]
	; 	call cvt2hex
	; 	print idstr

	; 	mov rax, qword [r12]
	; 	lea rdi, [tststr+17*2]
	; 	call cvt2hex
	; 	print tststr		

	; 	mov rax, qword [r12+8]
	; 	lea rdi, [tststr+17*2]
	; 	call cvt2hex
	; 	print tststr		

	; jmp _loop		


	cli
	hlt

	%include "IDT.inc"
	%include "../cvt2hex/cvt2hex.inc"


times 1024 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:
	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0
	efi_getch dq 0

	tststr dw  __utf16__(`0x0000000000000000\r\n\0`)


	divstr dw  __utf16__(`============================\r\n\0`)
	idstr dw   __utf16__(`ISR ID:   0x0000000000000000\r\n\0`)
	selstr dw  __utf16__(`Selector: 0x0000000000000000\r\n\0`)
	iststr dw  __utf16__(`IST:      0x0000000000000000\r\n\0`)
	typestr dw __utf16__(`Attrs:    0x0000000000000000\r\n\0`)
	ptrstr dw  __utf16__(`Address:  0x0000000000000000\r\n\0`)


	IDTR:
		.limit dw 0
		.base dq 0

	IDTR2:
		.limit dw 0
		.base dq 0

	key:
		.sccode dw 0
		.char dw 0

	sampleaddr dq 0x1234ABCD9876EF56

times 1024 - ($-$$) db 0 ;alignment
datasize equ $-$$
