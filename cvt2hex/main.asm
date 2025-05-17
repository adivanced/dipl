[BITS 64]
[DEFAULT REL]

%include "../jd9999_hdr_macro.inc"
jd9999_hdr_macro textsize, datasize, 0x0, textsize+datasize+1024


section .text follows=.header
start:
	sub rsp, 6*8+8 ; Copied from Charles AP's implementation, fix stack alignment issue (Thanks Charles AP!)

	mov qword [EFI_HANDLE], rcx
	mov qword [EFI_SYSTEM_TABLE], rdx

	mov rax, qword [EFI_SYSTEM_TABLE]
	mov rax, qword [rax+64]
	mov rax, qword [rax+8]
	mov qword [efi_print], rax

	;lea rax, [EFI_SYSTEM_TABLE]
	mov rax, qword [EFI_SYSTEM_TABLE]
	lea rdi, [numstr+17*2]
	call cvt2hex
	;lea rdx, [rdi]

	mov rcx, qword [EFI_SYSTEM_TABLE]
	mov rcx, qword [rcx+64]
	lea rdx, [numstr]
	sub rsp, 32
	call [efi_print]
	add rsp, 32

	mov rax, qword [EFI_HANDLE]
	lea rdi, [numstr+17*2]
	call cvt2hex

	mov rcx, qword [EFI_SYSTEM_TABLE]
	mov rcx, qword [rcx+64]
	lea rdx, [numstr]
	sub rsp, 32
	call [efi_print]
	add rsp, 32


	cli
	hlt

	;ret

;	cli
;	hlt


	%include "cvt2hex.inc"




times 1024 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:
	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0

	tststr dw __utf16__(`string \0`)
	numstr dw __utf16__(`0x0000000000000000\n`)


times 1024 - ($-$$) db 0 ;alignment
datasize equ $-$$
