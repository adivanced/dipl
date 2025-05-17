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

	call get_PCIe_BAR
	call get_FADT_BAR

	call get_MADT_BAR
	call conf_LAPIC
	call disable_PIC

	call PS2_init


	lea rdi, [ps2str0+27*2]
	call cvt2hex
	print ps2str0


	mov rax, qword [FADT]
	lea rdi, [fadtstr0+23*2]
	call cvt2hex
	print fadtstr0

	mov rax, qword [FADT]
	mov eax, dword [rax]
	lea rdi, [fadtstr1+20*2]
	call cvt2hex
	print fadtstr1

	mov rax, qword [FADT]
	movzx eax, word [rax+109]
	lea rdi, [fadtstr2+16*2]
	call cvt2hex
	print fadtstr2

	movzx eax, byte [PS2_port_1_working]
	lea rdi, [ps2str1+12*2]
	call cvt2hex
	print ps2str1

	movzx eax, byte [PS2_port_2_working]
	lea rdi, [ps2str2+12*2]
	call cvt2hex
	print ps2str2

	movzx eax, byte [single_channel_PS2]
	lea rdi, [ps2str3+13*2]
	call cvt2hex
	print ps2str3

	movzx eax, byte [port_1_dev_id+0]
	lea rdi, [ps2str4+13*2]
	call cvt2hex
	movzx eax, byte [port_1_dev_id+1]
	lea rdi, [ps2str4+18*2]
	call cvt2hex	
	print ps2str4	

	movzx eax, byte [port_2_dev_id+0]
	lea rdi, [ps2str5+13*2]
	call cvt2hex
	movzx eax, byte [port_2_dev_id+1]
	lea rdi, [ps2str5+18*2]
	call cvt2hex	
	print ps2str5	


	check_loop:
		pause
		mov rax, qword [kbd_cnt]
		cmp rax, qword [kbd_cnt_old]
	jne print_kbd
	e_print_kbd:
		mov rax, qword [mos_cnt]
		cmp rax, qword [mos_cnt_old]
	jne print_mos
	jmp check_loop

	print_kbd:
		inc qword [kbd_cnt_old]
		lea rdi, [kbd_str+21*2]
		call cvt2hex
		lea rax, [sccode_circ_buf]
		mov rbx, qword [sccode_circ_buf_ptr]
		cmp rbx, 0
		ja .dec_ptr
		mov rbx, 511
		jmp .skip_ptr
		.dec_ptr:
		dec rbx
		.skip_ptr:
		movzx rax, byte [rax+rbx]
		lea rdi, [kbd_str+26*2]
		call cvt2hex
		print kbd_str
	jmp e_print_kbd		


	print_mos:
		inc qword [mos_cnt_old]
		mov rax, qword [mouse_x]
		lea rdi, [mos_str+21*2]
		call cvt2hex
		mov rax, qword [mouse_y]
		lea rdi, [mos_str+40*2]
		call cvt2hex
		movzx rax, byte [mouse_l]
		lea rdi, [mos_str+45*2]
		call cvt2hex
		movzx rax, byte [mouse_m]
		lea rdi, [mos_str+50*2]
		call cvt2hex
		movzx rax, byte [mouse_r]
		lea rdi, [mos_str+55*2]
		call cvt2hex
		mov rax, qword [mouse_z]
		lea rdi, [mos_str+74*2]
		call cvt2hex

		print mos_str
	jmp check_loop


	cli
	hlt

	%include "../cvt2hex/cvt2hex.inc"
	%include "PS2.inc"
	%include "FADT.inc"
	%include "../PCIe/PCIe.inc"
	%include "../ioapic/ioapic.inc"
	%include "../apic/apic.inc"
	%include "../IDT/IDT.inc"
	%include "../MADT/MADT.inc"


times 5120 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:

	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0
	efi_getch dq 0

	tststr dw  __utf16__(`0x0000000000000000\r\n\0`)

	fadtstr0 dw __utf16__(`FADT: 0x0000000000000000\r\n\0`)
	fadtstr1 dw __utf16__(`FADT sign: 0x00000000\r\n\0`)
	fadtstr2 dw __utf16__(`FADT PS2?: 0x0000\r\n\0`)

	ps2str0 dw __utf16__(`PS2_init: 0x0000000000000000\r\n\0`)
	ps2str1 dw __utf16__(`PS2 p1?: 0x00\r\n\0`)
	ps2str2 dw __utf16__(`PS2 p2?: 0x00\r\n\0`)
	ps2str3 dw __utf16__(`PS2 1ch?: 0x00\r\n\0`)
	ps2str4 dw __utf16__(`PS2 p1id: 0x00 0x00\r\n\0`)
	ps2str5 dw __utf16__(`PS2 p2id: 0x00 0x00\r\n\0`)


	kbd_str dw  __utf16__(`KBD 0x0000000000000000 0x00\r\n\0`)
	mos_str dw  __utf16__(`MOS 0x0000000000000000 0x0000000000000000 0x00 0x00 0x00 0x0000000000000000\r\n\0`)




	lapic dq 0
	MADT dq 0

	kbd_cnt dq 0
	mos_cnt dq 0

	kbd_cnt_old dq 0
	mos_cnt_old dq 0


	%include "FADT_data.inc"
	%include "../PCIe/PCIe_data.inc"
	%include "PS2_data.inc"

times 4096 - ($-$$) db 0 ;alignment
datasize equ $-$$
