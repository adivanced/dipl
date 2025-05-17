[BITS 64]
[DEFAULT REL]

%include "../jd9999_hdr_macro.inc"
jd9999_hdr_macro textsize, datasize, 0x0, textsize+datasize+1024

%macro print 1
	mov rcx, qword [EFI_SYSTEM_TABLE]
	mov rcx, qword [rcx+64]
	lea rdx, [%1]
	;sub rsp, 32
	call [efi_print]
	;add rsp, 32
%endmacro

%macro getch 1
	mov rcx, qword [EFI_SYSTEM_TABLE]
	mov rcx, qword [rcx+48]
	lea rdx, [%1]
	;sub rsp, 32
	call [efi_getch]
	;add rsp, 32
%endmacro

%macro print_MMAP_info 0
	mov rax, qword [MMAP.rval]
	lea rdi, [MMAP_tststr+28*2]
	call cvt2hex

	mov rax, [MMAP.size]
	lea rdi, [MMAP_tststr+52*2]
	call cvt2hex	

	mov rax, [MMAP.key]
	lea rdi, [MMAP_tststr+75*2]
	call cvt2hex

	mov rax, [MMAP.descsize]
	lea rdi, [MMAP_tststr+103*2]
	call cvt2hex

	mov rax, [MMAP.descver]
	lea rdi, [MMAP_tststr+130*2]
	call cvt2hex

	print MMAP_tststr
%endmacro

%macro print_MMAP_desc 0
	mov rax, qword [iter]
	xor rdx, rdx
	mov rcx, qword [MMAP.descsize]
	mul rcx
	lea rcx, [MMAP.map]

	lea r12, [rax+rcx] ; r12 is preserved across function calls (hopefully)
	mov r13, qword [MMAP.descsize]
	shr r13, 3

	mov rax, qword [iter]
	lea rdi, [MMAP_descstr+29*2]
	call cvt2hex
	print MMAP_descstr

	%%_loop:
		mov rax, qword [r12]
		lea rdi, [tststr+17*2]
		call cvt2hex
		print tststr
		add r12, 8
		dec r13
	jnz %%_loop
%endmacro

%macro clscr 0
	mov rcx, qword [EFI_SYSTEM_TABLE]
	mov rcx, qword [rcx+64]
	call [efi_clscr]
%endmacro 


section .text follows=.header
start:
	sub rsp, 6*8+8 ; Copied from Charles AP's implementation, fix stack alignment issue (Thanks Charles AP!)

	mov qword [EFI_HANDLE], rcx
	mov qword [EFI_SYSTEM_TABLE], rdx

	mov rax, qword [EFI_SYSTEM_TABLE]
	mov rax, qword [rax+64]
	mov rax, qword [rax+8]
	mov qword [efi_print], rax

	print boundstr

	mov rax, qword [EFI_SYSTEM_TABLE]
	mov rax, qword [rax+64]
	mov rax, qword [rax+48]
	mov qword [efi_clscr], rax	

	mov rax, qword [EFI_SYSTEM_TABLE]
	mov rax, qword [rax+48]
	mov rax, qword [rax+8]
	mov qword [efi_getch], rax



	mov rax, qword [EFI_SYSTEM_TABLE]
	mov rax, qword [rax+96]
	mov rax, qword [rax+56]
	mov qword [efi_get_mmap], rax

	; mov rax, qword [efi_get_mmap]
	; lea rdi, [tststr+17*2]
	; call cvt2hex


	lea rcx, [MMAP.size]
	xor rdx, rdx
	lea r8, [MMAP.key]
	lea r9, [MMAP.descsize]
	lea r10, [MMAP.descver]
	;sub rsp, 32
	mov qword [rsp+32], r10
	call [efi_get_mmap]
	;add rsp, 32
	mov qword [MMAP.rval], rax

	print sampstr


	lea rcx, [MMAP.size]
	lea rdx, [MMAP.map]
	lea r8, [MMAP.key]
	lea r9, [MMAP.descsize]
	lea r10, [MMAP.descver]
	mov qword [rsp+32], r10
	call [efi_get_mmap]
	mov qword [MMAP.rval], rax

	;print boundstr

	clscr
	print boundstr
	print_MMAP_info
	print_MMAP_desc
	print boundstr

	_loop:
		getch key
		test rax, rax
		jz gotkey
		;print tststr
	jmp _loop

	gotkey:
		cmp word [key.char], __utf16__(`a`)
		jz back
		cmp word [key.char], __utf16__(`d`)
		jz fwd
	jmp _loop

	back:
		cmp qword [iter], 0
		jz _loop
		dec qword [iter]
		clscr
		print boundstr
		print MMAP_tststr
		print_MMAP_desc
		print boundstr		
	jmp _loop

	fwd:
		mov rax, qword [iter]
		xor rdx, rdx
		mov rcx, qword [MMAP.descsize]
		mul rcx	

		add rax, qword [MMAP.descsize]
		cmp rax, qword [MMAP.size]
		jae _loop
		inc qword [iter]
		clscr
		print boundstr
		print MMAP_tststr
		print_MMAP_desc
		print boundstr		
	jmp _loop

	cli
	hlt


%include "../cvt2hex/cvt2hex.inc"


times 2048 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:
	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0
	efi_clscr dq 0
	efi_getch dq 0
	efi_get_mmap dq 0

	MMAP:
		.rval dq 0
		.size dq 0
		.key dq 0
		.descsize dq 0
		.descver dq 0
		.map times 8192 db 0

	iter dq 0

	boundstr dw __utf16__(`=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\r\n\0`)

	tststr dw __utf16__(`0x0000000000000000\r\n\0`)

	sampstr dw __utf16__(`ahahahahahahh \0`)

	MMAP_tststr dw __utf16__(`MMAP: rval:0x0000000000000000 size:0x0000000000000000 key:0x0000000000000000 descsize:0x0000000000000000 descver:0x0000000000000000\r\n\0`)
	MMAP_descstr dw __utf16__(`Descriptor  0x0000000000000000:\r\n\0`)

	key:
		.sccode dw 0
		.char dw 0



times 8192 + 1024 - ($-$$) db 0 ;alignment
datasize equ $-$$
