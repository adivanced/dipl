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

%macro print_NVMe_registers 0

	mov rax, qword [NVMe_BAR]
	mov rax, qword [rax+0x0]
	lea rdi, [NVMe_CAP_str+50]
	call cvt2hex
	print NVMe_CAP_str

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0x8]
	lea rdi, [NVMe_VS_str+34]
	call cvt2hex
	print NVMe_VS_str

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0xC]
	lea rdi, [NVMe_INTMS_str+34]
	call cvt2hex
	print NVMe_INTMS_str

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0xF]
	lea rdi, [NVMe_INTMC_str+34]
	call cvt2hex
	print NVMe_INTMC_str

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0x14]
	lea rdi, [NVMe_CC_str+34]
	call cvt2hex
	print NVMe_CC_str

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0x1C]
	lea rdi, [NVMe_CSTS_str+34]
	call cvt2hex
	print NVMe_CSTS_str

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0x20]
	lea rdi, [NVMe_NSSR_str+34]
	call cvt2hex
	print NVMe_NSSR_str

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0x24]
	lea rdi, [NVMe_AQA_str+34]
	call cvt2hex
	print NVMe_AQA_str

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0x28]
	lea rdi, [NVMe_ASQ_str+50]
	call cvt2hex
	print NVMe_ASQ_str

	mov rax, qword [NVMe_BAR]
	mov rax, qword [rax+0x30]
	lea rdi, [NVMe_ACQ_str+50]
	call cvt2hex
	print NVMe_ACQ_str

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0x38]
	lea rdi, [NVMe_CMBLOC_str+34]
	call cvt2hex
	print NVMe_CMBLOC_str	

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0x1000]
	lea rdi, [NVMe_SQ0TDBL_str+34]
	call cvt2hex
	print NVMe_SQ0TDBL_str

	mov rax, qword [NVMe_BAR]
	mov eax, dword [rax+0x1004]
	lea rdi, [NVMe_CQ0HDBL_str+34]
	call cvt2hex
	print NVMe_CQ0HDBL_str

	
%endmacro

%macro print_NVMe_vars 0
	mov rax, qword [NVMe_PCIe_BAR]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rax, qword [NVMe_BAR]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rax, qword [NVMe_cur]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rax, qword [NVMe_n]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	xor eax, eax
	mov al, byte [NVMe_IRQ]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov eax, dword [NVMe_total_LBA]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	

	xor eax, eax
	mov al, byte [NVMe_LBA]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	

	xor eax, eax
	mov al, byte [NVMe_atail]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	xor eax, eax
	mov al, byte [NVMe_iotail]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rax, qword [GPT_entry_LBA_end]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	mov rax, qword [GPT_entry_cur_LBA]
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

%endmacro

; 0x7E9F0541

%macro print_NVMe_ANS 3 ; %1 - nrows, %2 - ncols, %3 - BAR
	;lea rsi, [DISK_ID_BUF]
	mov rsi, %3
	;lea rsi, [TMPBUF]
	;mov rsi, 0x174000
	xor r15, r15 ; counter
	cld
	push %1
	push %2
	%%_loop:
		mov rax, r15
		lea rdi, [numstr+8]
		call cvt2hex

		xor rax, rax
		lodsd
		lea rdi, [dwrdstr+20]
		call cvt2hex

		push rsi
		push r15

		print numstr
		print dwrdstr

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


%macro print_NVMe_CTRLID 0
	cld
	mov rsi, 0x174000
	xor eax, eax
	lodsb
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	cld
	mov rsi, 0x174001
	xor eax, eax
	lodsb
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; flags

	cld
	mov rsi, 0x174002
	xor eax, eax
	lodsw
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; cid

	cld
	mov rsi, 0x174004
	xor eax, eax
	lodsd
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; nsid

	cld
	mov rsi, 0x174008
	xor eax, eax
	lodsq
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; rsvd[0]

	cld
	mov rsi, 0x174010
	xor eax, eax
	lodsq
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; rsvd[1]

	cld
	mov rsi, 0x174018
	xor eax, eax
	lodsq
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; prp1

	cld
	mov rsi, 0x174020
	xor eax, eax
	lodsq
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; prp2

	cld
	mov rsi, 0x174028
	xor eax, eax
	lodsd
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; cns

	cld
	mov rsi, 0x17402C
	xor eax, eax
	lodsd
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; rsvd11[0]

	cld
	mov rsi, 0x174030
	xor eax, eax
	lodsd
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; rsvd11[1]

	cld
	mov rsi, 0x174034
	xor eax, eax
	lodsd
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; rsvd11[2]

	cld
	mov rsi, 0x174038
	xor eax, eax
	lodsd
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; rsvd11[3]

	cld
	mov rsi, 0x17403C
	xor eax, eax
	lodsd
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr; rsvd11[4]

%endmacro


%macro print_NVMe_PCIe_registers 0
	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax]
	lea rdi, [tststr2+18]
	call cvt2hex
	print tststr2

	mov rax, qword [NVMe_PCIe_BAR]
	mov ax, word [rax+4]
	and rax, 0xFFFF
	lea rdi, [tststr3+10]
	call cvt2hex
	print tststr3

	mov rax, qword [NVMe_PCIe_BAR]
	mov ax, word [rax+6]
	and rax, 0xFFFF
	lea rdi, [tststr3+10]
	call cvt2hex
	print tststr3	

%endmacro 


%macro print_NVMe_PCIe 0
	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x00]
	lea rdi, [str0+30]
	call cvt2hex
	print str0

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x04]
	lea rdi, [str1+30]
	call cvt2hex
	print str1

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x08]
	lea rdi, [str2+30]
	call cvt2hex
	print str2

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x0C]
	lea rdi, [str3+30]
	call cvt2hex
	print str3

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x10]
	lea rdi, [str4+30]
	call cvt2hex
	print str4

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x14]
	lea rdi, [str5+30]
	call cvt2hex
	print str5

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x18]
	lea rdi, [str6+30]
	call cvt2hex
	print str6

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x1C]
	lea rdi, [str7+30]
	call cvt2hex
	print str7

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x20]
	lea rdi, [str8+30]
	call cvt2hex
	print str8

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x24]
	lea rdi, [str9+30]
	call cvt2hex
	print str9

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x28]
	lea rdi, [strA+30]
	call cvt2hex
	print strA

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x2C]
	lea rdi, [strB+30]
	call cvt2hex
	print strB

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x30]
	lea rdi, [strC+30]
	call cvt2hex
	print strC

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x34]
	lea rdi, [strD+30]
	call cvt2hex
	print strD

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x38]
	lea rdi, [strE+30]
	call cvt2hex
	print strE

	mov rax, qword [NVMe_PCIe_BAR]
	mov eax, dword [rax+0x3C]
	lea rdi, [strF+30]
	call cvt2hex
	print strF
%endmacro

%macro print_NVMe_CQ_entry_N 1
	cld
	mov rsi, 0x171000
	mov rcx, %1
	shl rcx, 4
	add rsi, rcx
	lodsq 
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr ; The definition of this field is Fabrics response type specific.

	cld
	mov rsi, 0x171008
	mov rcx, %1
	shl rcx, 4
	add rsi, rcx
	xor eax, eax
	lodsw
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr ; SQ Head Pointer (SQHD)

	cld
	mov rsi, 0x17100C
	mov rcx, %1
	shl rcx, 4
	add rsi, rcx
	xor eax, eax
	lodsw
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr ; Command id

	cld
	mov rsi, 0x17100E
	mov rcx, %1
	shl rcx, 4
	add rsi, rcx
	xor eax, eax
	lodsw
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr ; STS

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

	call probe_NVMe

	lea rdi, [tststr+34]
	call cvt2hex
	print tststr


	mov rax, qword [start_LBA]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr

	movzx rax, byte [NVMe_max_trans]
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr	

	mov rax, 0
	mov rcx, 1
	mov rdi, 0x178000
	call NVMe_read


	print_NVMe_ANS 10, 14, 0x178000

	mov rax, 0
	mov rcx, 1
	lea rsi, [dataStart]
	call NVMe_write


	; mov rax, 1
	; mov rbx, 8
	; call PCIe_get_cl_subcl_n
	; mov qword [NVMe_n], rax

	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr

	; mov rax, 1
	; mov rbx, 8
	; mov rcx, 1
	; call PCIe_get_cl_subcl_adr
	; mov qword [NVMe_PCIe_BAR], rax

	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr

	; mov rax, qword [NVMe_PCIe_BAR]
	; mov ebx, dword [rax+0x10]
	; mov eax, dword [rax+0x14]
	; shl rax, 32
	; or rax, rbx
	; and rax, 0xFFFFFFFFFFFFFFF0
	; mov qword [NVMe_BAR], rax

	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr


	; call init_MTRR
	; call get_vacant_MTRR
	; mov rbx, qword [NVMe_BAR]
	; mov rcx, 0x4000
	; xor rdx, rdx
	; mov rdi, 39
	; call set_MTRR_pair

	; call NVMe_init
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr	

	; mov rax, qword [NVMe_BAR]
	; mov eax, dword [rax+0x1000]
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr		


	; print_NVMe_registers


	; movzx rax, byte [NVMe_LBA]
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr

; 	movzx rax, byte [NVMe_LBA]
; 	lea rdi, [tststr+34]
; 	call cvt2hex
; 	print tststr



; 	mov rax, 0
; 	mov rbx, 2
; 	mov rcx, 1
; 	mov rdx, 0
; 	mov rdi, 0x178000
; 	call NVMe_io


; [default abs]
; 	movzx rax, byte [0x174000+77]
; [default rel]
; 	lea rdi, [tststr+34]
; 	call cvt2hex
; 	print tststr	


	;print_NVMe_ANS 10, 14, 0x170000
	;print_NVMe_ANS 25, 14, 0x171000
	;print_NVMe_ANS 10, 6, 0x174000
	;print_NVMe_ANS 10, 6, 0x175000
	;print_NVMe_ANS 10, 6, 0x176000
	;print_NVMe_ANS 10, 14, 0x172000
	;print_NVMe_ANS 10, 14, 0x173000
	print_NVMe_ANS 10, 14, 0x178000


	;print_NVMe_CTRLID

	; mov rax, 0x17404D
	; movzx rax, byte [rax]
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr

	; mov rax, 0x174200
	; movzx rax, byte [rax]
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr	

	; mov rax, 0x174201
	; movzx rax, byte [rax]
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr



	; pop rax
	; lea rdi, [tststr+34]
	; call cvt2hex
	; print tststr


	cli
	hlt


	%include "../cvt2hex/cvt2hex.inc"
	%include "../PCIe/PCIe.inc"
	%include "../disk/disk_data.inc"
	%include "NVMe.inc"

	%include "../MTRR/MTRR.inc"

times 5120 - ($-$$) db 0 ;alignment
textsize equ $-$$

section .data follows=.text
dataStart:

	disknamestr dw __utf16__(`                                    \r\n\0`)

	EFI_HANDLE dq 0
	EFI_SYSTEM_TABLE dq 0

	efi_print dq 0
	efi_getch dq 0

	tststr dw  __utf16__(`0x0000000000000000\r\n\0`)
	tststr2 dw __utf16__(`0x00000000\r\n\0`)
	tststr3 dw __utf16__(`0x0000\r\n\0`)
	tststr4 dw __utf16__(`0x00\r\n\0`)

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

	NVMe_CAP_str     dw __utf16__(`CAP     0x0000000000000000\r\n\0`)
	NVMe_VS_str      dw __utf16__(`VS      0x00000000\r\n\0`)
	NVMe_INTMS_str   dw __utf16__(`INTMS   0x00000000\r\n\0`)
	NVMe_INTMC_str   dw __utf16__(`INTMC   0x00000000\r\n\0`)
	NVMe_CC_str      dw __utf16__(`CC      0x00000000\r\n\0`)
	NVMe_CSTS_str    dw __utf16__(`CSTS    0x00000000\r\n\0`)
	NVMe_NSSR_str    dw __utf16__(`NSSR    0x00000000\r\n\0`)
	NVMe_AQA_str     dw __utf16__(`AQA     0x00000000\r\n\0`)
	NVMe_ASQ_str     dw __utf16__(`ASQ     0x0000000000000000\r\n\0`)
	NVMe_ACQ_str     dw __utf16__(`ACQ     0x0000000000000000\r\n\0`)
	NVMe_CMBLOC_str  dw __utf16__(`CMBLOC  0x00000000\r\n\0`)
	NVMe_CMBSZ_str   dw __utf16__(`CMBSZ   0x00000000\r\n\0`)
	NVMe_BPINFO_str  dw __utf16__(`BPINFO  0x00000000\r\n\0`)
	NVMe_BPRSEL_str  dw __utf16__(`BPRSEL  0x00000000\r\n\0`)
	NVMe_BPMBL_str   dw __utf16__(`BPMBL   0x0000000000000000\r\n\0`)
	NVMe_CMBMSC_str  dw __utf16__(`CMBMSC  0x0000000000000000\r\n\0`)
	NVMe_CMBSTS_str  dw __utf16__(`CMBSTS  0x00000000\r\n\0`)
	NVMe_CMBEBS_str  dw __utf16__(`CMBEBS  0x00000000\r\n\0`)
	NVMe_CMBSWTP_str dw __utf16__(`CMBSWTP 0x00000000\r\n\0`)
	NVMe_NSSD_str    dw __utf16__(`NSSD    0x00000000\r\n\0`)
	NVMe_CRTO_str    dw __utf16__(`CRTO    0x00000000\r\n\0`)
	NVMe_PMRCAP_str  dw __utf16__(`PMRCAP  0x00000000\r\n\0`)
	NVMe_PMRCTL_str  dw __utf16__(`PMRCTL  0x00000000\r\n\0`)
	NVMe_PMRSTS_str  dw __utf16__(`PMRSTS  0x00000000\r\n\0`)
	NVMe_PMREBS_str  dw __utf16__(`PMREBS  0x00000000\r\n\0`)
	NVMe_PMRSWTP_str dw __utf16__(`PMRSWTP 0x00000000\r\n\0`)
	NVMe_PMRMSCL_str dw __utf16__(`PMRMSCL 0x00000000\r\n\0`)
	NVMe_PMRMSCU_str dw __utf16__(`PMRMSCU 0x00000000\r\n\0`)
	NVMe_SQ0TDBL_str dw __utf16__(`SQ0TDBL 0x00000000\r\n\0`)
	NVMe_CQ0HDBL_str dw __utf16__(`CQ0HDBL 0x00000000\r\n\0`)

	numstr dw  __utf16__(`0x000\0`)
	wrdstr dw  __utf16__(` 0x0000 \0`)
	dwrdstr dw  __utf16__(` 0x00000000 \0`)
	qwrdstr dw  __utf16__(` 0x0000000000000000 \0`)
	bytestr dw  __utf16__(` 0x00 \0`)

	newlnstr dw __utf16__(`\r\n\0`) 

	%include "../PCIe/PCIe_data.inc"
	%include "NVMe_data.inc"

	%include "../MTRR/MTRR_data.inc"

	TMPBUF times 512 db 0



times 4096 - ($-$$) db 0 ;alignment
datasize equ $-$$
