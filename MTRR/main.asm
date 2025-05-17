[BITS 64]
[DEFAULT REL]

%include "../jd9999_hdr_macro.inc"
jd9999_hdr_macro textsize, datasize, 0x0, textsize+datasize+1024

%macro print 1
	mov rcx, qword [EFI_SYSTEM_TABLE]
	mov rcx, qword [rcx+64]
	lea rdx, [%1]
	sub rsp, 32
	call [efi_print]
	add rsp, 32
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

	mov ecx, 0xFE
	rdmsr
	shl rdx, 32
	or rax, rdx

	mov rcx, rax
	and rcx, 0xFF
	mov qword [dyn_MTRR_avalible], rcx

	lea rdi, [MTRR_n_str+26*2]
	call cvt2hex
	print MTRR_n_str

	mov ecx, 0x2FF
	rdmsr
	shl rdx, 32
	or rax, rdx
	lea rdi, [MTRR_deftype_str+30*2]
	call cvt2hex
	print MTRR_deftype_str

	;push 0
	;push 0x200

	call get_vacant_MTRR
	mov rbx, 0xE0000000
	mov rcx, 0x4000
	xor rdx, rdx
	mov rdi, 39
	call set_MTRR_pair


	_loop:
		mov rcx, qword [it1]
		rdmsr 
		shl rdx, 32
		or rax, rdx
		lea rdi, [MTRR_str2+27*2]
		call cvt2hex

		mov rcx, qword [it1]
		inc rcx
		rdmsr 
		shl rdx, 32
		or rax, rdx
		lea rdi, [MTRR_str5+27*2]
		call cvt2hex

		print MTRR_str2
		print MTRR_str5


		add qword [it1], 2
		inc qword [it0]
		mov rax, qword [dyn_MTRR_avalible]
		cmp rax, qword [it0]
	ja _loop

	call init_MTRR
	mov rax, qword [dyn_MTRR_avalible]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	call get_vacant_MTRR

	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	cli
	hlt


	%include "../cvt2hex/cvt2hex.inc"
	%include "MTRR.inc"

times 4096 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:
	
	it0 dq 0
	it1 dq 0x200

	disknamestr dw __utf16__(`                                    \r\n\0`)

	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0
	efi_getch dq 0

	tststr dw  __utf16__(`0x0000000000000000\r\n\0`)

	MTRR_n_str dw __utf16__(`MTRRCAP: 0x0000000000000000\r\n\0`)
	MTRR_deftype_str dw __utf16__(`MTRRDEFTYPE: 0x0000000000000000\r\n\0`)
	MTRR_str0 dw __utf16__(`MTRR # 0x0000 \0`)
	MTRR_str3 dw __utf16__(`PhysBASE: \r\n\0`)
	MTRR_str1 dw __utf16__(`PhysMASK: \r\n\0`)
	MTRR_str2 dw __utf16__(`PhysBASE: 0x0000000000000000  \0`)
	MTRR_str5 dw __utf16__(`PhysMASK: 0x0000000000000000\r\n\0`)


	%include "MTRR_data.inc"


	numstr dw  __utf16__(`0x00\0`)
	wrdstr dw  __utf16__(` 0x0000 \0`)
	newlnstr dw __utf16__(`\r\n\0`) 


times 3072 - ($-$$) db 0 ;alignment
datasize equ $-$$
