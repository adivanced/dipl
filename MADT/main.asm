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

%macro print_all 0
	print madt_str1
	print boundstr

	mov rax, r12
	lea rdi, [offstr+27*2]
	call cvt2hex
	print offstr

	mov r13, qword [MADT]

	xor rax, rax
	mov al, byte [r13+r12]
	lea rdi, [madt_typeX_str+15*2]
	call cvt2hex

	xor rax, rax
	mov al, byte [r13+r12+1]
	lea rdi, [madt_typeX_str+34*2]
	call cvt2hex

	print madt_typeX_str

	mov al, byte [r13+r12]
	test al, al
	jz %%_type0
	cmp al, 1
	jz %%_type1
	cmp al, 2
	jz %%_type2
	cmp al, 3
	jz %%_type3
	cmp al, 4
	jz %%_type4
	cmp al, 5
	jz %%_type5
	cmp al, 9
	jz %%_type9

	jmp %%end

	%%_type0:
		xor rax, rax
		mov al, byte [r13+r12+2]
		lea rdi, [madt_type0_str1+21*2]
		call cvt2hex

		xor rax, rax
		mov al, byte [r13+r12+3]
		lea rdi, [madt_type0_str2+11*2]
		call cvt2hex

		mov eax, dword [r13+r12+4]
		lea rdi, [madt_type0_str3+21*2]
		call cvt2hex

		print madt_type0_str1
	jmp %%end

	%%_type1:
		xor rax, rax
		mov al, byte [r13+r12+2]
		lea rdi, [madt_type1_str1+15*2]
		call cvt2hex

		xor rax, rax
		mov al, byte [r13+r12+3]
		lea rdi, [madt_type1_str2+12*2]
		call cvt2hex

		mov eax, dword [r13+r12+4]
		lea rdi, [madt_type1_str3+22*2]
		call cvt2hex

		mov eax, dword [r13+r12+8]
		lea rdi, [madt_type1_str4+38*2]
		call cvt2hex

		print madt_type1_str1
	jmp %%end

	%%_type2:
		xor rax, rax
		mov al, byte [r13+r12+2]
		lea rdi, [madt_type2_str1+14*2]
		call cvt2hex

		xor rax, rax
		mov al, byte [r13+r12+3]
		lea rdi, [madt_type2_str2+14*2]
		call cvt2hex

		mov eax, dword [r13+r12+4]
		lea rdi, [madt_type2_str3+33*2]
		call cvt2hex

		mov ax, word [r13+r12+8]
		lea rdi, [madt_type2_str4+17*2]
		call cvt2hex

		print madt_type2_str1
	jmp %%end

	%%_type3:
		xor rax, rax
		mov al, byte [r13+r12+2]
		lea rdi, [madt_type3_str1+14*2]
		call cvt2hex

		xor rax, rax
		mov al, byte [r13+r12+3]
		lea rdi, [madt_type3_str2+12*2]
		call cvt2hex		

		xor rax, rax
		mov ax, word [r13+r12+4]
		lea rdi, [madt_type3_str3+17*2]
		call cvt2hex

		xor rax, rax
		mov eax, dword [r13+r12+6]
		lea rdi, [madt_type3_str4+33*2]
		call cvt2hex

		print madt_type3_str1
	jmp %%end

	%%_type4:
		xor rax, rax
		mov al, byte [r13+r12+2]
		lea rdi, [madt_type4_str1+21*2]
		call cvt2hex

		mov ax, word [r13+r12+3]
		lea rdi, [madt_type4_str2+17*2]
		call cvt2hex

		mov al, byte [r13+r12+5]
		lea rdi, [madt_type4_str3+9*2]
		call cvt2hex	

		print madt_type4_str1	
	jmp %%end

	%%_type5:
		xor rax, rax
		mov ax, word [r13+r12+2]
		lea rdi, [madt_type5_str1+14*2]
		call cvt2hex

		mov rax, qword [r13+r12+4]
		lea rdi, [madt_type5_str2+39*2]
		call cvt2hex

		print madt_type5_str1
	jmp %%end

	%%_type9:
		xor rax, rax
		mov ax, word [r13+r12+2]
		lea rdi, [madt_type9_str1+14*2]
		call cvt2hex

		mov eax, dword [r13+r12+4]
		lea rdi, [madt_type9_str2+36*2]
		call cvt2hex

		mov eax, dword [r13+r12+8]
		lea rdi, [madt_type9_str3+21*2]
		call cvt2hex

		mov eax, dword [r13+r12+0xC]
		lea rdi, [madt_type9_str4+17*2]
		call cvt2hex

		print madt_type9_str1
	jmp %%end

%%end:

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

	mov rax, qword [MADT]
	lea rdi, [madt_str1+27*2]
	call cvt2hex

	mov r12, qword [MADT]

	mov eax, dword [r12]
	lea rdi, [madt_str2+25*2]
	call cvt2hex

	mov eax, dword [r12+4]
	lea rdi, [madt_str3+22*2]
	call cvt2hex

	xor rax, rax
	mov al, byte [r12+0x8]
	lea rdi, [madt_str4+18*2]
	call cvt2hex

	xor rax, rax
	mov al, byte [r12+0x9]
	lea rdi, [madt_str5+18*2]
	call cvt2hex

	xor rax, rax
	xor rbx, rbx
	mov eax, dword [r12+0xa]
	mov bx, word [r12+0xa+4]
	shl rax, 16
	or rax, rbx
	lea rdi, [madt_str6+25*2]
	call cvt2hex

	mov rax, qword [r12+0x10]
	lea rdi, [madt_str7+36*2]
	call cvt2hex

	mov eax, dword [r12+0x18]
	lea rdi, [madt_str8+28*2]
	call cvt2hex

	mov eax, dword [r12+0x1c]
	lea rdi, [madt_str9+26*2]
	call cvt2hex

	mov eax, dword [r12+0x20]
	lea rdi, [madt_strA+32*2]
	call cvt2hex

	mov eax, dword [r12+0x24]
	lea rdi, [madt_strB+30*2]
	call cvt2hex

	mov eax, dword [r12+0x28]
	lea rdi, [madt_strC+25*2]
	call cvt2hex

	;print madt_str1

	mov r14, 0x2c ; prev offs
	mov r12, 0x2c ; first offs
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
		cmp r12, 0x2c
		jz _loop
		mov r12, 0x2c
		print_all
	jmp _loop

	fwd:
		mov rbx, qword [MADT]
		xor rax, rax
		mov al, byte [rbx+r12+1]
		mov ebx, dword [rbx+4]
		lea rdx, [r12+rax]
		cmp rdx, rbx
		jae _loop
		add r12, rax
		print_all
	jmp _loop 


	cli
	hlt

	%include "MADT.inc"
	%include "../cvt2hex/cvt2hex.inc"




times 4096 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:
	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0
	efi_getch dq 0

	tststr dw __utf16__(`0x0000000000000000\r\n\0`)

	madt_str1 dw __utf16__(`MADT BAR: 0x0000000000000000\r\n`)
	madt_str2 dw __utf16__(`MADT Signature: 0x00000000\r\n`)
	madt_str3 dw __utf16__(`MADT Length: 0x00000000\r\n`)
	madt_str4 dw __utf16__(`MADT Revision: 0x00\r\n`)
	madt_str5 dw __utf16__(`MADT Checksum: 0x00\r\n`)
	madt_str6 dw __utf16__(`MADT OEMID: 0x000000000000\r\n`)
	madt_str7 dw __utf16__(`MADT OEM Table ID: 0x0000000000000000\r\n`)
	madt_str8 dw __utf16__(`MADT OEM Revision: 0x00000000\r\n`)
	madt_str9 dw __utf16__(`MADT Creator ID: 0x00000000\r\n`)
	madt_strA dw __utf16__(`MADT Creator Revision: 0x00000000\r\n`)
	madt_strB dw __utf16__(`MADT Local APIC BAR: 0x00000000\r\n`)
	madt_strC dw __utf16__(`MADT PIC Flags: 0x00000000\r\n\0`)

	madt_typeX_str dw __utf16__(`Entry Type: 0x00 Record Length 0x00\r\n\0`)

	madt_type0_str1 dw __utf16__(`ACPI Processor ID 0x00\r\n`)
	madt_type0_str2 dw __utf16__(`ACPI ID 0x00\r\n`)
	madt_type0_str3 dw __utf16__(`Entry Flags 0x00000000\r\n\0`)

	madt_type1_str1 dw __utf16__(`I/O APIC ID 0x00\r\n`)
	madt_type1_str2 dw __utf16__(`Reserved 0x00\r\n`)
	madt_type1_str3 dw __utf16__(`I/O APIC BAR 0x00000000\r\n`)
	madt_type1_str4 dw __utf16__(`Global System Interrupt Base 0x00000000\r\n\0`)

	madt_type2_str1 dw __utf16__(`Bus Source 0x00\r\n`)
	madt_type2_str2 dw __utf16__(`IRQ Source 0x00\r\n`)
	madt_type2_str3 dw __utf16__(`Global System Interrupt 0x00000000\r\n`)
	madt_type2_str4 dw __utf16__(`Entry Flags 0x0000\r\n\0`)

	madt_type3_str1 dw __utf16__(`NMI Source 0x00\r\n`)
	madt_type3_str2 dw __utf16__(`Reserved 0x00\r\n`)
	madt_type3_str3 dw __utf16__(`Entry Flags 0x0000\r\n`)
	madt_type3_str4 dw __utf16__(`Global System Interrupt 0x00000000\r\n\0`)

	madt_type4_str1 dw __utf16__(`ACPI Processor ID 0x00\r\n`)
	madt_type4_str2 dw __utf16__(`Entry Flags 0x0000\r\n`)
	madt_type4_str3 dw __utf16__(`LINT# 0x00\r\n\0`)

	madt_type5_str1 dw __utf16__(`Reserved 0x0000\r\n`)
	madt_type5_str2 dw __utf16__(`64-bit Local APIC BAR 0x0000000000000000\r\n\0`)

	madt_type9_str1 dw __utf16__(`Reserved 0x0000\r\n`)
	madt_type9_str2 dw __utf16__(`Processors local x2APIC ID 0x00000000\r\n`)
	madt_type9_str3 dw __utf16__(`Entry Flags 0x00000000\r\n`)
	madt_type9_str4 dw __utf16__(`ACPI ID 0x00000000\r\n\0`)

	boundstr dw __utf16__(`=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\r\n\0`)

	offstr dw __utf16__(`__Offset: 0x0000000000000000\r\n\0`)

	RSDP dq 0
	XSDT dq 0
	MADT dq 0

	key:
		.sccode dw 0
		.char dw 0


times 4096 - ($-$$) db 0 ;alignment
datasize equ $-$$
