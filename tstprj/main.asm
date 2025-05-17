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

	mov rax, qword [EFI_SYSTEM_TABLE]
	mov rax, qword [rax+48]
	mov rax, qword [rax+8]
	mov qword [efi_getch], rax

	call exportfunc_fill

	lea rdi, [exportfunc_data]
	call bench_start

	cli
	hlt

	%include "../HPET_driver/HPET_driver_generic.inc"
	%include "../MADT/MADT.inc"
	%include "../ioapic/ioapic.inc"
	%include "../apic/apic.inc"
	%include "../IDT/IDT.inc"	
	%include "../cvt2hex/cvt2hex.inc"

	%include "exportfunc.inc"
	
	; rax - our string
	print_func:
		mov rcx, qword [EFI_SYSTEM_TABLE]
		mov rcx, qword [rcx+64]
		mov rdx, rax
		sub rsp, 32
		call [efi_print]
		add rsp, 32
	ret

	intfunc:
		inc qword [counter]
		;push rax
		mov qword [timerstash], rax
		mov rax, 0xFEE000B0
		mov dword [rax], 0
		;pop rax
		mov rax, qword [timerstash]
	iretq

align 16
bench_start:
incbin "code.o"

times 5120 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:
	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0
	efi_getch dq 0

	counter dq 0
	timerstash dq 0

	tststr dw  __utf16__(`0x0000000000000000\r\n\0`)

	HPET_acpi dq 0
	HPET_BAR  dq 0

	MADT dq 0
	XSDT dq 0
	MCFG dq 0
	RSDP dq 0

	io_apic dq 0
	io_apic_index dd 0

	lapic dq 0

	HPET dq 0

	%include "exportfunc_data.inc"
times 403456 - ($-$$) db 0 ;alignment
datasize equ $-$$