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

	call get_MADT_BAR

	call get_ioapic_number

	xor rax, rax

	call get_ioapic_BAR
	mov qword [IOAPIC_BAR], rax

	xor rax, rax
	call get_IRQn_redirect

	mov r12, rdx

	lea rdi, [tststr+17*2]
	call cvt2hex
	print tststr

	mov rax, r12
	lea rdi, [tststr+17*2]
	call cvt2hex
	print tststr



	; mov dword [r12], 0x14 ; IOREGSEL (select)
	; mov eax, dword [r12+0x10] ; IOWIN (data)

	; mov dword [r12], 0x15
	; mov ebx, dword [r12+0x10]
	; shl rbx, 32
	; or rax, rbx




	cli
	hlt

	%include "ioapic.inc"
	%include "../MADT/MADT.inc"
	%include "../cvt2hex/cvt2hex.inc"


times 1024 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:
	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0
	efi_getch dq 0

	tststr dw __utf16__(`0x0000000000000000\r\n\0`)

	RSDP dq 0
	XSDT dq 0
	MADT dq 0

	IOAPIC_BAR dq 0

	gdtr_ dq 0

	key:
		.sccode dw 0
		.char dw 0


times 1024 - ($-$$) db 0 ;alignment
datasize equ $-$$
