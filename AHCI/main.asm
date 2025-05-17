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

%macro print_AHCI_PCIe 0
	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x00]
	lea rdi, [str0+30]
	call cvt2hex
	print str0

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x04]
	lea rdi, [str1+30]
	call cvt2hex
	print str1

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x08]
	lea rdi, [str2+30]
	call cvt2hex
	print str2

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x0C]
	lea rdi, [str3+30]
	call cvt2hex
	print str3

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x10]
	lea rdi, [str4+30]
	call cvt2hex
	print str4

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x14]
	lea rdi, [str5+30]
	call cvt2hex
	print str5

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x18]
	lea rdi, [str6+30]
	call cvt2hex
	print str6

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x1C]
	lea rdi, [str7+30]
	call cvt2hex
	print str7

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x20]
	lea rdi, [str8+30]
	call cvt2hex
	print str8

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x24]
	lea rdi, [str9+30]
	call cvt2hex
	print str9

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x28]
	lea rdi, [strA+30]
	call cvt2hex
	print strA

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x2C]
	lea rdi, [strB+30]
	call cvt2hex
	print strB

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x30]
	lea rdi, [strC+30]
	call cvt2hex
	print strC

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x34]
	lea rdi, [strD+30]
	call cvt2hex
	print strD

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x38]
	lea rdi, [strE+30]
	call cvt2hex
	print strE

	mov rax, qword [AHCI_PCIe]
	mov eax, dword [rax+0x3C]
	lea rdi, [strF+30]
	call cvt2hex
	print strF
%endmacro

%macro print_AHCI_MMIO 0
	mov rax, qword [AHCI]
	mov eax, dword [rax]
	lea rdi, [str_GHC_CAP+19*2]
	call cvt2hex
	print str_GHC_CAP 

	mov rax, qword [AHCI]
	mov eax, dword [rax+0x4]
	lea rdi, [str_GHC_GHC+19*2]
	call cvt2hex
	print str_GHC_GHC 

	mov rax, qword [AHCI]
	mov eax, dword [rax+0x8]
	lea rdi, [str_GHC_IS+19*2]
	call cvt2hex
	print str_GHC_IS 

	mov rax, qword [AHCI]
	mov eax, dword [rax+0xC]
	lea rdi, [str_GHC_PI+19*2]
	call cvt2hex
	print str_GHC_PI 

	mov rax, qword [AHCI]
	mov eax, dword [rax+0x10]
	lea rdi, [str_GHC_VS+19*2]
	call cvt2hex
	print str_GHC_VS 

	mov rax, qword [AHCI]
	mov eax, dword [rax+0x14]
	lea rdi, [str_GHC_CCC_CTL+19*2]
	call cvt2hex
	print str_GHC_CCC_CTL 

	mov rax, qword [AHCI]
	mov eax, dword [rax+0x18]
	lea rdi, [str_GHC_CCC_PORTS+19*2]
	call cvt2hex
	print str_GHC_CCC_PORTS 

	mov rax, qword [AHCI]
	mov eax, dword [rax+0x1C]
	lea rdi, [str_GHC_EM_LOC+19*2]
	call cvt2hex
	print str_GHC_EM_LOC 

	mov rax, qword [AHCI]
	mov eax, dword [rax+0x20]
	lea rdi, [str_GHC_EM_CTL+19*2]
	call cvt2hex
	print str_GHC_EM_CTL 

	mov rax, qword [AHCI]
	mov eax, dword [rax+0x24]
	lea rdi, [str_GHC_CAP2+19*2]
	call cvt2hex
	print str_GHC_CAP2 

	mov rax, qword [AHCI]
	mov eax, dword [rax+0x28]
	lea rdi, [str_GHC_BOHC+19*2]
	call cvt2hex
	print str_GHC_BOHC 
%endmacro

%macro print_AHCI_probe_drives 0
	mov rsi, qword [AHCI]
	call AHCI_get_N_disks
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rsi, qword [AHCI]
	mov rcx, 0
	call AHCI_get_disk_id
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rsi, qword [AHCI]
	mov rcx, 1
	call AHCI_get_disk_id
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr
%endmacro

%macro print_AHCI_PORTN_MMIO 1 ; arg - portN, imm
	mov rax, qword [AHCI]
	add rax, 0x100 + 0x80*%1	
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0]
	lea rdi, [str_PxCLB+18*2]
	call cvt2hex
	print str_PxCLB

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x4]
	lea rdi, [str_PxCLBU+18*2]
	call cvt2hex
	print str_PxCLBU

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x8]
	lea rdi, [str_PxFB+18*2]
	call cvt2hex
	print str_PxFB

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0xC]
	lea rdi, [str_PxFBU+18*2]
	call cvt2hex
	print str_PxFBU

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x10]
	lea rdi, [str_PxIS+18*2]
	call cvt2hex
	print str_PxIS

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x14]
	lea rdi, [str_PxIE+18*2]
	call cvt2hex
	print str_PxIE

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x18]
	lea rdi, [str_PxCMD+18*2]
	call cvt2hex
	print str_PxCMD

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x20]
	lea rdi, [str_PxTFD+18*2]
	call cvt2hex
	print str_PxTFD

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x24]
	lea rdi, [str_PxSIG+18*2]
	call cvt2hex
	print str_PxSIG

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x28]
	lea rdi, [str_PxSSTS+18*2]
	call cvt2hex
	print str_PxSSTS

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x2c]
	lea rdi, [str_PxSCTL+18*2]
	call cvt2hex
	print str_PxSCTL

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x30]
	lea rdi, [str_PxSERR+18*2]
	call cvt2hex
	print str_PxSERR

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x34]
	lea rdi, [str_PxSACT+18*2]
	call cvt2hex
	print str_PxSACT

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x38]
	lea rdi, [str_PxCI+18*2]
	call cvt2hex
	print str_PxCI

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x3C]
	lea rdi, [str_PxSNTF+18*2]
	call cvt2hex
	print str_PxSNTF

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x40]
	lea rdi, [str_PxFBS+18*2]
	call cvt2hex
	print str_PxFBS

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x44]
	lea rdi, [str_PxDEVSLP+18*2]
	call cvt2hex
	print str_PxDEVSLP

	mov rsi, qword [AHCI]
	add rsi, 0x100 + 0x80*%1
	mov eax, dword [rsi+0x70]
	lea rdi, [str_PxVS+18*2]
	call cvt2hex
	print str_PxVS

%endmacro


%macro print_SATA_IDENTIFY_DRIVE 0
	lea rsi, [DISK_ID_BUF]
	mov rcx, -1
	%%_loop:
		inc rcx 
		mov rax, rcx
		push rcx
		push rsi
		lea rdi, [numstr+6]
		call cvt2hex
		print numstr
		pop rsi
		lodsw
		push rsi
		lea rdi, [wrdstr+12]
		call cvt2hex
		print wrdstr
		mov rax, qword [rsp+8]
		inc rax
		mov rbx, rax
		and rax, 0xFFFFFFFFFFFFFFFC
		sub rbx, rax
		jz %%_enter
		%%e_enter:
		pop rsi
		pop rcx
		cmp rcx, 78
	jnz %%_loop
	jmp %%_end

	%%_enter:
		print newlnstr
	jmp %%e_enter

	%%_end:
	print newlnstr
%endmacro

%macro print_SATAID_by_word 2 ; %1 - nrows, %2 - ncols
	lea rsi, [DISK_ID_BUF]
	xor r15, r15 ; counter
	cld
	push %1
	push %2
	%%_loop:
		mov rax, r15
		lea rdi, [numstr+6]
		call cvt2hex

		xor rax, rax
		lodsw
		lea rdi, [wrdstr+12]
		call cvt2hex

		push rsi
		push r15

		print numstr
		print wrdstr

		pop r15
		pop rsi
		cld
		inc r15
		dec qword [rsp]
		jnz %%_loop
		mov qword [rsp], %2
		push rsi
		push r15
		print newlnstr
		pop r15
		pop rsi
		cld
		dec qword [rsp+8]
	jnz %%_loop
	add rsp, 16
%endmacro

%macro print_GPT_LBA1 0
	lea rax, [DISK_ID_BUF]
	mov rax, qword [rax]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF]
	mov eax, dword [rax+8]
	lea rdi, [tststr1+18]
	call cvt2hex
	print tststr1

	lea rax, [DISK_ID_BUF]
	mov eax, dword [rax+0xC]
	lea rdi, [tststr1+18]
	call cvt2hex
	print tststr1

	lea rax, [DISK_ID_BUF]
	mov eax, dword [rax+0x10]
	lea rdi, [tststr1+18]
	call cvt2hex
	print tststr1

	lea rax, [DISK_ID_BUF]
	mov rax, qword [rax+0x18]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF]
	mov rax, qword [rax+0x20]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF]
	mov rax, qword [rax+0x28]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF]
	mov rax, qword [rax+0x30]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF]
	mov rax, qword [rax+0x38]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF]
	mov rax, qword [rax+0x40]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF]
	mov rax, qword [rax+0x48]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF]
	mov eax, dword [rax+0x50]
	lea rdi, [tststr1+18]
	call cvt2hex
	print tststr1

	lea rax, [DISK_ID_BUF]
	mov eax, dword [rax+0x54]
	lea rdi, [tststr1+18]
	call cvt2hex
	print tststr1

	lea rax, [DISK_ID_BUF]
	mov eax, dword [rax+0x58]
	lea rdi, [tststr1+18]
	call cvt2hex
	print tststr1

%endmacro

%macro print_GPT_LBA2 1
	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x0]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x8]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x10]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x18]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x20]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x28]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x30]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x38]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x40]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x48]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x50]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	lea rax, [DISK_ID_BUF+%1]
	mov rax, qword [rax+0x58]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	
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

	print strstr

	call get_PCIe_BAR

	; mov qword [PCIe], rax
	; mov rbx, rdx
	; and rbx, 0xFF
	; mov qword [PCIe_enbsn], rbx
	; mov rbx, rdx
	; shr rbx, 8
	; and rbx, 0xFF
	; mov qword [PCIe_stbsn], rbx
	; mov rbx, rdx
	; shr rbx, 16
	; and rbx, 0xFFFF
	; mov qword [PCIe_seggn], rbx

	print strstr

	call probe_AHCI

	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rax, qword [AHCI]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rax, qword [N_AHCI]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rax, qword [AHCI_n_disks]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	

	mov rax, qword [AHCI_diskn]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	

	mov rax, qword [AHCI_disk_selected]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	


	mov rax, qword [GPT_entry_cur_LBA]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	

	mov rax, qword [GPT_entry_LBA_end]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	

	mov eax, dword [GPT_entry_n]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	

	mov eax, dword [GPT_entry_sz]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	

	mov rax, qword [start_LBA]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr		


	mov rax, 0
	mov rcx, 3
	lea rsi, [dataStart]
	call AHCI_write

	mov rax, 0
	mov rcx, 1
	lea rdi, [DISK_ID_BUF]
	call AHCI_read

	; mov rax, 1
	; mov rbx, 6
	; mov rcx, 0
	; call PCIe_get_cl_subcl_adr
	; mov qword [AHCI_PCIe], rax

	; lea rdi, [pcie_str+44]
	; call cvt2hex
	; print pcie_str

	; mov rax, qword [AHCI_PCIe]
	; mov eax, dword [rax+0x24]
	; mov qword [AHCI], rax 

	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr




	;print_AHCI_PCIe
	;print_AHCI_MMIO
	;print_AHCI_PORTN_MMIO 3

	; mov rdi, qword [AHCI]
	; mov rcx, 2
	; call AHCI_conf_drive

	; mov rax, 0x800
	; mov rcx, 1
	; mov rdx, 0
	; lea rdi, [smth_data]
	; mov rsi, qword [AHCI]
	; call AHCI_write_sectors
;0x04 41 40 34

	 ; lea rdi, [tststr+34]
	 ; call cvt2hex
	 ; print tststr

	; mov rax, 2
	; mov rcx, 1
	; mov rdx, 0
	; lea rdi, [DISK_ID_BUF]
	; mov rsi, qword [AHCI]
	; call AHCI_read_sectors
;0x00 50 40 34

	; mov rax, 0x800
	; mov rcx, 1
	; lea rsi, [smth_data]
	; call AHCI_write

	; mov rax, 0x800
	; mov rcx, 1
	; lea rdi, [DISK_ID_BUF]
	; call AHCI_read




	;print_DRIVE_INFO	
	;print_AHCI_MMIO
	;print_AHCI_PORTN_MMIO 2

	;print_SATA_IDENTIFY_DRIVE
	print_SATAID_by_word 10, 6
; real SATA HDD: "      TMA51C4T0DJ02L"

	;print_GPT_LBA1
	;print_GPT_LBA2 0


	; okay, the rw works! Now only thing left is implementing a coherent driver based on this stuff

	; mov rax, 0x71040
	; ;mov rax, 0x72400
	; mov eax, dword [rax]
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr

	; mov rax, 0x71044
	; ;mov rax, 0x72404
	; mov eax, dword [rax]
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr

	; mov rax, 0x71048
	; ;mov rax, 0x72408
	; mov eax, dword [rax]
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr

	; mov rax, 0x7104C
	; ;mov rax, 0x7240C
	; mov eax, dword [rax]
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr





	cli
	hlt


	%include "../cvt2hex/cvt2hex.inc"
	%include "AHCI.inc"
	%include "../disk/disk_data.inc"
	%include "../PCIe/PCIe.inc"

times 4096 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:

	disknamestr dw __utf16__(`                                    \r\n\0`)

	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0
	efi_getch dq 0

	tststr dw  __utf16__(`0x0000000000000000\r\n\0`)
	tststr2 dw  __utf16__(`0x0000000000000000 \0`)
	

	numstr dw  __utf16__(`0x00\0`)
	wrdstr dw  __utf16__(` 0x0000 \0`)
	newlnstr dw __utf16__(`\r\n\0`) 

	pcie_str dw __utf16__(`PCIe 0x0000000000000000\r\n\0`)
	str0  dw __utf16__(`0x00  0x00000000\r\n\0`)	
	str1  dw __utf16__(`0x04  0x00000000\r\n\0`)	
	str2  dw __utf16__(`0x08  0x00000000\r\n\0`)	
	str3  dw __utf16__(`0x0C  0x00000000\r\n\0`)	
	str4  dw __utf16__(`0x10  0x00000000\r\n\0`)	
	str5  dw __utf16__(`0x14  0x00000000\r\n\0`)	
	str6  dw __utf16__(`0x18  0x00000000\r\n\0`)	
	str7  dw __utf16__(`0x1C  0x00000000\r\n\0`)	
	str8  dw __utf16__(`0x20  0x00000000\r\n\0`)	
	str9  dw __utf16__(`0x24  0x00000000\r\n\0`)	
	strA  dw __utf16__(`0x28  0x00000000\r\n\0`)	
	strB  dw __utf16__(`0x2C  0x00000000\r\n\0`)	
	strC  dw __utf16__(`0x30  0x00000000\r\n\0`)	
	strD  dw __utf16__(`0x34  0x00000000\r\n\0`)	
	strE  dw __utf16__(`0x38  0x00000000\r\n\0`)	
	strF  dw __utf16__(`0x3C  0x00000000\r\n\0`)

	str_GHC_CAP       dw __utf16__(`CAP       0x00000000\r\n\0`)
	str_GHC_GHC       dw __utf16__(`GHC       0x00000000\r\n\0`)
	str_GHC_IS        dw __utf16__(`IS        0x00000000\r\n\0`)
	str_GHC_PI        dw __utf16__(`PI        0x00000000\r\n\0`)
	str_GHC_VS        dw __utf16__(`VS        0x00000000\r\n\0`)
	str_GHC_CCC_CTL   dw __utf16__(`CCC_CTL   0x00000000\r\n\0`)
	str_GHC_CCC_PORTS dw __utf16__(`CCC_PORTS 0x00000000\r\n\0`)
	str_GHC_EM_LOC    dw __utf16__(`EM_LOC    0x00000000\r\n\0`)
	str_GHC_EM_CTL    dw __utf16__(`EM_CTL    0x00000000\r\n\0`)
	str_GHC_CAP2      dw __utf16__(`CAP2      0x00000000\r\n\0`)
	str_GHC_BOHC      dw __utf16__(`BOHC      0x00000000\r\n\0`)

	str_PxCLB      dw __utf16__(`PxCLB    0x00000000\r\n\0`)
	str_PxCLBU     dw __utf16__(`PxCLBU   0x00000000\r\n\0`)
	str_PxFB       dw __utf16__(`PxFB     0x00000000\r\n\0`)
	str_PxFBU      dw __utf16__(`PxFBU    0x00000000\r\n\0`)
	str_PxIS       dw __utf16__(`PxIS     0x00000000\r\n\0`)
	str_PxIE       dw __utf16__(`PxIE     0x00000000\r\n\0`)
	str_PxCMD      dw __utf16__(`PxCMD    0x00000000\r\n\0`)
	str_PxTFD      dw __utf16__(`PxTFD    0x00000000\r\n\0`)
	str_PxSIG      dw __utf16__(`PxSIG    0x00000000\r\n\0`)
	str_PxSSTS     dw __utf16__(`PxSSTS   0x00000000\r\n\0`)
	str_PxSCTL     dw __utf16__(`PxSCTL   0x00000000\r\n\0`)
	str_PxSERR     dw __utf16__(`PxSERR   0x00000000\r\n\0`)
	str_PxSACT     dw __utf16__(`PxSACT   0x00000000\r\n\0`)
	str_PxCI       dw __utf16__(`PxCI     0x00000000\r\n\0`)
	str_PxSNTF     dw __utf16__(`PxSNTF   0x00000000\r\n\0`)
	str_PxFBS      dw __utf16__(`PxFBS    0x00000000\r\n\0`)
	str_PxDEVSLP   dw __utf16__(`PxDEVSLP 0x00000000\r\n\0`)
	str_PxVS       dw __utf16__(`PxVS     0x00000000\r\n\0`)

	align 2
	smth_data db 0x22, 0x80, 0x33, 0x19, 0xFF, 0xFF, 0xCC, 0xDD, 0x0A


	tststr_long dw __utf16__(`0x00000000 0x00000000 0x00000000 0x00000000\r\n\0`)

	key:
		.sccode dw 0
		.char dw 0

	PCIe dq 0
	PCIe_seggn dq 0
	PCIe_stbsn dq 0
	PCIe_enbsn dq 0

	strstr dw __utf16__(`smth!!!\r\n\0`)

	%include "AHCI_data.inc"
	%include "../PCIe/PCIe_data.inc"

times 4096 - ($-$$) db 0 ;alignment
datasize equ $-$$
