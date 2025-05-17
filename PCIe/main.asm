[BITS 64]
[DEFAULT REL]

%include "../jd9999_hdr_macro.inc"
jd9999_hdr_macro textsize, datasize, 0x0, textsize+datasize+1024

%macro print 1
	mov rax, 2
	mov rcx, qword [EFI_SYSTEM_TABLE]
	mov rcx, qword [rcx+64]
	lea rdx, [%1]
	sub rsp, 32
	call [efi_print]
	add rsp, 32	
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

	call get_PCIe_BAR

	mov qword [PCIe_bar], rax
	mov dword [seg_g_num], edx

	lea rdi, [tststr+17*2]
	call cvt2hex
	print tststr

	xor rax, rax
	mov ax, word [seg_g_num]
	lea rdi, [tststr+17*2]
	call cvt2hex

	print tststr

	xor rax, rax
	mov al, byte [start_bus_num]
	lea rdi, [tststr+17*2]
	call cvt2hex

	print tststr

	xor rax, rax
	mov al, byte [end_bus_num] 
	lea rdi, [tststr+17*2]
	call cvt2hex

	print tststr



	cli
	hlt

	ret


	%include "PCIe.inc"
	%include "../cvt2hex/cvt2hex.inc"

;	cli
;	hlt





times 1024 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:
	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0

	RSDP dq 0
	XSDT dq 0
	MCFG dq 0

	PCIe_bar dq 0
	seg_g_num dw 0
	start_bus_num db 0
	end_bus_num db 0


	tststr dw __utf16__(`0x0000000000000000\n\r\0`)


times 1024 - ($-$$) db 0 ;alignment
datasize equ $-$$
