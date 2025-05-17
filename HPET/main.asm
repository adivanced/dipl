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


	call get_ACPI_HPET_BAR
	mov qword [HPET_acpi], rax
	lea rdi, [ptr_str+82]
	call cvt2hex
	print ptr_str

	mov rax, qword [HPET_acpi]
	mov eax, dword [rax+0]
	lea rdi , [signstr+82]
	call cvt2hex
	print signstr

	mov rax, qword [HPET_acpi]
	mov eax, dword [rax+4]
	lea rdi , [lengstr+82]
	call cvt2hex
	print lengstr	

	mov rcx, qword [HPET_acpi]
	xor rax, rax
	mov al, byte [rcx+8]
	lea rdi , [revistr+82]
	call cvt2hex
	print revistr	

	mov rcx, qword [HPET_acpi]
	xor rax, rax
	mov al, byte [rcx+9]
	lea rdi, [chekstr+82]
	call cvt2hex
	print chekstr

	mov rax, qword [HPET_acpi]
	mov rax, qword [rax+8]
	shr rax, 16
	lea rdi, [oemdstr+82]
	call cvt2hex
	print oemdstr

	mov rax, qword [HPET_acpi]
	mov rax, qword [rax+16]
	lea rdi, [oemtstr+82]
	call cvt2hex
	print oemtstr

	mov rax, qword [HPET_acpi]
	mov eax, dword [rax+24]
	lea rdi, [oemrstr+82]
	call cvt2hex
	print oemrstr

	mov rax, qword [HPET_acpi]
	mov eax, dword [rax+28]
	lea rdi, [cridstr+82]
	call cvt2hex
	print cridstr

	mov rax, qword [HPET_acpi]
	mov eax, dword [rax+32]
	lea rdi, [crrestr+82]
	call cvt2hex
	print crrestr

	mov rax, qword [HPET_acpi]
	mov eax, dword [rax+36]
	lea rdi, [tbidstr+82]
	call cvt2hex
	print tbidstr

	mov rax, qword [HPET_acpi]
	mov eax, dword [rax+40]
	lea rdi, [bar1str+82]
	call cvt2hex
	print bar1str

	mov rax, qword [HPET_acpi]
	mov rax, qword [rax+44]
	lea rdi, [bar2str+82]
	call cvt2hex
	print bar2str

	mov rcx, qword [HPET_acpi]
	xor rax, rax
	mov al, byte [rcx+52]
	lea rdi, [numbstr+82]
	call cvt2hex
	print numbstr

	mov rcx, qword [HPET_acpi]
	xor rax, rax
	mov ax, word [rcx+53]	
	lea rdi, [cntmstr+82]
	call cvt2hex
	print cntmstr

	mov rax, qword [HPET_acpi]
	mov rax, qword [rax+55]
	lea rdi, [ppoastr+82]
	call cvt2hex
	print ppoastr

	print divistr

	mov rax, qword [HPET_acpi]
	mov rax, qword [rax+44]
	mov qword [HPET_BAR], rax

	mov rax, qword [rax]
	lea rdi, [gcirstr+82]
	call cvt2hex
	print gcirstr

	mov rax, qword [HPET_BAR]
	mov rax, qword [rax+0x10]
	lea rdi, [gcfrstr+82]
	call cvt2hex
	print gcfrstr

	mov rax, qword [HPET_BAR]
	mov rax, qword [rax+0x20]
	lea rdi, [gisrstr+82]
	call cvt2hex
	print gisrstr

	mov rax, qword [HPET_BAR]
	mov rax, qword [rax+0xF0]
	lea rdi, [mcvrstr+82]
	call cvt2hex
	print mcvrstr

	mov rax, qword [HPET_BAR]
	mov rax, qword [rax+0x100]
	lea rdi, [t0crstr+82]
	call cvt2hex
	print t0crstr

	mov rax, qword [HPET_BAR]
	mov rax, qword [rax+0x108]
	lea rdi, [t0mrstr+82]
	call cvt2hex
	print t0mrstr

	mov rax, qword [HPET_BAR]
	mov rax, qword [rax+0x110]
	lea rdi, [t0frstr+82]
	call cvt2hex
	print t0frstr

	cli
	hlt



	%include "HPET.inc"
	%include "../cvt2hex/cvt2hex.inc"


times 2048 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:
	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0
	efi_getch dq 0

	tststr dw  __utf16__(`0x0000000000000000\r\n\0`)

	ptr_str dw __utf16__(`HPET ACPI table ptr:    0x0000000000000000\r\n\0`)
	signstr dw __utf16__(`HPET signature:                 0x00000000\r\n\0`)
	lengstr dw __utf16__(`HPET length:                    0x00000000\r\n\0`)
	revistr dw __utf16__(`HPET revision:                        0x00\r\n\0`)
	chekstr dw __utf16__(`HPET checksum:                        0x00\r\n\0`)
	oemdstr dw __utf16__(`HPET OEMID:                 0x000000000000\r\n\0`)
	oemtstr dw __utf16__(`HPET OEM table id:      0x0000000000000000\r\n\0`)
	oemrstr dw __utf16__(`HPET OEM revision:              0x00000000\r\n\0`)
	cridstr dw __utf16__(`HPET creator id:                0x00000000\r\n\0`)
	crrestr dw __utf16__(`HPET creator revision:          0x00000000\r\n\0`)
	tbidstr dw __utf16__(`HPET e timer block id:  0x0000000000000000\r\n\0`)
	bar1str dw __utf16__(`HPET BAR (hdword):              0x00000000\r\n\0`)
	bar2str dw __utf16__(`HPET BAR (lqword):      0x0000000000000000\r\n\0`)
	numbstr dw __utf16__(`HPET Number:                          0x00\r\n\0`)
	cntmstr dw __utf16__(`HPET main counter min:              0x0000\r\n\0`)
	ppoastr dw __utf16__(`HPET page prot&OEM att: 0x0000000000000000\r\n\0`)
	divistr dw __utf16__(`==========================================\r\n\0`)
	gcirstr dw __utf16__(`General cap&id register 0x0000000000000000\r\n\0`)
	gcfrstr dw __utf16__(`General config register 0x0000000000000000\r\n\0`)
	gisrstr dw __utf16__(`General int_status reg  0x0000000000000000\r\n\0`)
	mcvrstr dw __utf16__(`Main counter value reg  0x0000000000000000\r\n\0`)
	t0crstr dw __utf16__(`Timer0 cap register     0x0000000000000000\r\n\0`)
	t0mrstr dw __utf16__(`Timer0 comparator reg   0x0000000000000000\r\n\0`)
	t0frstr dw __utf16__(`Timer0 FSB_int register 0x0000000000000000\r\n\0`)








	HPET_acpi dq 0
	HPET_BAR  dq 0

	key:
		.sccode dw 0
		.char dw 0

times 3072 - ($-$$) db 0 ;alignment
datasize equ $-$$
