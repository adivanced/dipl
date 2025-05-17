[BITS 64]


; AHCI driver. No need for a full-fledged driver, AHCI is already initialized by EFI

; AHCI HBA memory registers:
%define AHCI_CMDLIST 0x0000000000070000
%define AHCI_RECV_FIS 0x0000000000071000
%define AHCI_CMDTABLE 0x0000000000072400 

%define HBA_CAP 0x00
%define HBA_GHC 0x04
%define HBA_IS 0x08
%define HBA_PI 0x0C
%define HBA_VS 0x10
%define HBA_CCC_CTL 0x14
%define HBA_CCC_PORTS 0x18
%define HBA_EM_LOC 0x1C
%define HBA_EM_CTL 0x20
%define HBA_CAP2 0x24
%define HBA_BOHC 0x28

%define HBA_VENDOR_SPECIFIC_REGISTERS 0xA0

%define HBA_PORT_DISTANCE 0x80
%define HBA_PORTn_OFFSET(n) (0x100 + HBA_PORT_DISTANCE*n)


%define HBA_PxCLB 0x00
%define HBA_PxCLBU 0x04
%define HBA_PxFB 0x08
%define HBA_PxFBU 0x0C
%define HBA_PxIS 0x10
%define HBA_PxIE 0x14
%define HBA_PxCMD 0x18
%define HBA_PxTFD 0x20
%define HBA_PxSIG 0x24
%define HBA_PxSSTS 0x28
%define HBA_PxSCTL 0x2C
%define HBA_PxSERR 0x30
%define HBA_PxSACT 0x34
%define HBA_PxCI 0x38
%define HBA_PxSNTF 0x3C
%define HBA_PxFBS 0x40
%define HBA_PxDEVSLP 0x44
%define HBA_PxVS 0x70

%macro debug_print 0
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push rbp
	; mov rcx, qword [EFI_SYSTEM_TABLE]
	; mov rcx, qword [rcx+64]
	; mov rdx, rsi
	; sub rsp, 32
	; call [efi_print]
	; add rsp, 32
	mov rax, qword [rsi]
	test rax, rax
	jz %%_skip
	lea rdi, [tststr2+34]
	call cvt2hex
	print tststr2
	%%_skip:
	pop rbp
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
%endmacro


%macro debug_print_2 0
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
	push rbp
 	mov rax, rdx
	lea rdi, [tststr+34]
	call cvt2hex
	print tststr
	pop rbp
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
%endmacro

; rsi - AHCI BAR
; returns the amount of disks connected
AHCI_get_N_disks:
	xor rax, rax ; counter
	mov ebx, dword [rsi+HBA_PI] ; PI bit position register
	add rsi, HBA_PORTn_OFFSET(0) + HBA_PxSSTS

	.test_port:
		bt ebx, 0
		jnc .no_drive
		cmp dword [rsi], 0
		jz .no_drive
		inc rax
		.no_drive:
		add rsi, HBA_PORT_DISTANCE
		shr ebx, 1
	jnz .test_port
ret
	

; rsi - AHCI BAR
; rcx - PortN 
; returns the actual PortN as of AHCI memmap
AHCI_get_disk_id:
	xor rax, rax ; counter of valid disks
	mov ebx, dword [rsi+HBA_PI]
	add rsi, HBA_PORTn_OFFSET(0) + HBA_PxSSTS
	xor rdx, rdx ; overall port counter

	.test_port:
		bt ebx, 0
		jnc .no_drive
		cmp dword [rsi], 0
		jz .no_drive
		cmp rax, rcx
		je .found
		inc rax
		.no_drive:
		inc rdx
		add rsi, HBA_PORT_DISTANCE
		shr rbx, 1
	jnz .test_port
	mov rax, -1
ret
	.found:
	mov rax, rdx
ret



; rdi - AHCI BAR
; rcx - PortN
; configures the selected port with a drive attached
AHCI_conf_drive:
	push rdi
	cld
	shl rcx, 7
	lea rdi, [rdi+rcx+0x100] ; get the PORTn MMIO BAR

	and dword [rdi+HBA_PxCMD], 0x0FFFFFEE
	mov dword [rdi+HBA_PxCI], 0


	
	mov rax, AHCI_CMDLIST 
	stosd ; Offset 00h: PxCLB – Port x Command List Base Address
	shr rax, 32
	stosd ; Offset 04h: PxCLBU – Port x Command List Base Address Upper 32-bits
	mov rax, AHCI_CMDLIST + 0x1000
	stosd ; Offset 08h: PxFB – Port x FIS Base Address
	shr rax, 32
	xor eax, eax
	stosd ; Offset 0Ch: PxFBU – Port x FIS Base Address Upper 32-bits
	stosd ; Offset 10h: PxIS – Port x Interrupt Status
	stosd ; Offset 14h: PxIE – Port x Interrupt Enable

	;sub rsp, 512
	;pop rdi ; get AHCI BAR 
	lea rsi, [DISK_ID_BUF]
	; id the AHCI drive:



	iddrive:
		mov rdi, AHCI_CMDLIST
		mov eax, 0x00010005 ; 1 PRDTL Entry, Command FIS Length = 16 bytes
		stosd ; DW 0 - Description Information
		xor eax, eax
		stosd ; DW 1 - Command Status
		mov eax, AHCI_CMDTABLE
		stosd ; DW 2 - Command Table Base Address
		xor eax, eax
		stosd ; DW 3 - Command Table Base Address Upper
		stosd
		stosd
		stosd
		stosd ; DW 4 - 7 are reserved

		mov rdi, AHCI_CMDTABLE ; Build a command table for Port 0
		mov eax, 0x00EC8027 ; EC identify, bit 15 set, fis 27 H2D
		stosd ; feature 7:0, command, c, fis
		xor eax, eax
		stosd ; device, lba 23:16, lba 15:8, lba 7:0
		stosd ; feature 15:8, lba 47:40, lba 39:32, lba 31:24
		stosd ; control, ICC, count 15:8, count 7:0
		mov rdi, AHCI_CMDTABLE + 0x80
		mov rax, rsi
		stosd ; Data Base Address
		shr rax, 32
		stosd ; Data Base Address Upper
		xor eax, eax
		stosd ; Reserved
		mov eax, 0x1FF 
		stosd ; Description info

		pop rdi
		lea rdi, [rdi+rcx+0x100]
		mov dword [rdi+0x10], 0 ; Port X int status
		or dword [rdi+0x18], 10001b ; Port Cmd & Sts ; FRE, ST
		mov dword [rdi+0x38], 1 ; Command Issue, Execute Command Slot 0

		.iddrive_poll:
			mov eax, dword [rdi+0x38]
			test eax, eax
		jnz .iddrive_poll

		and dword [rdi+0x18], 0xFFFFFFEE ; Port Cmd & Sts ; FRE, ST
ret






; rax - starting sector
; rcx - N sectors to read
; rdx - disk N
; rdi - ptr to data
; rsi - AHCI BAR
AHCI_read_sectors:
	cld
	shl rdx, 7
	lea rsi, [rsi+rdx+0x100] ; get PortN MMIO BAR

	and dword [rsi+HBA_PxCMD], 0xFFFFFFEE
	mov dword [rsi+HBA_PxCI], 0

	mov rbx, rdi ; save ptr to data in rbx
	mov edi, dword [rsi+HBA_PxCLB]
	mov edx, dword [rsi+HBA_PxCLBU]
	shl rdx, 32
	or rdi, rdx
	mov rdx, rax ; N sectors to read in rdx
	
	mov eax, 0x00010005
	stosd
	xor eax, eax
	stosd
	mov rax, AHCI_CMDTABLE
	stosd
	shr rax, 32
	stosd
	xor eax, eax
	stosd
	stosd
	stosd
	stosd

	mov rdi, AHCI_CMDTABLE
	mov eax, 0x00258027
	stosd
	mov rax, rdx
	shl rax, 36
	shr rax, 36
	bts rax, 30
	stosd
	mov rax, rdx
	shr rax, 24
	stosd
	mov eax, ecx
	;or eax, 0x25000000
	stosd
	xor eax, eax
	stosd

	mov rdi, AHCI_CMDTABLE + 0x80
	mov rax, rbx
	stosd
	shr rax, 32
	stosd
	xor eax, eax
	stosd
	mov eax, ecx
	shl eax, 9
	dec eax
	stosd

	mov dword [rsi+HBA_PxIS], 0
	or dword [rsi+HBA_PxCMD], 10001b
	mov dword [rsi+HBA_PxCI], 1

	.poll:
		mov eax, dword [rsi+HBA_PxCI]
		test eax, eax
	jnz .poll

	and dword [rsi+0x18], 0xFFFFFFEE

	mov edx, dword [rsi+HBA_PxCLBU]
	mov eax, dword [rsi+HBA_PxCLB]
	shl rdx, 32
	or rax, rdx
	mov eax, dword [rax+4]
ret


; rax - staring sector
; rcx - n sectors
; rdx - disk N
; rdi - data ptr
; rsi - AHCI BAR

; clobs: rax, rcx, rdx, rdi, rsi
AHCI_write_sectors:
	cld
	shl rdx, 7
	lea rsi, [rsi+rdx+0x100]

	and dword [rsi+HBA_PxCMD], 0xFFFFFFEE
	mov dword [rsi+HBA_PxCI], 0

	mov rbx, rdi
	mov edi, dword [rsi+HBA_PxCLB]
	mov edx, dword [rsi+HBA_PxCLBU]
	shl rdx, 32
	or rdi, rdx
	mov rdx, rax

	mov eax, 0x00010045
	stosd
	xor eax, eax
	stosd
	mov rax, AHCI_CMDTABLE
	stosd
	shr rax, 32
	stosd
	xor eax, eax
	stosd
	stosd
	stosd
	stosd

	mov rdi, AHCI_CMDTABLE
	mov eax, 0x00358027
	stosd
	mov rax, rdx
	shl rax, 36
	shr rax, 36
	bts rax, 30
	stosd
	mov rax, rdx
	shr rax, 24
	stosd
	mov eax, ecx
	;or eax, 0x35000000
	stosd
	xor eax, eax
	stosd

	mov rdi, AHCI_CMDTABLE + 0x80
	mov rax, rbx
	stosd
	shr rax, 32
	stosd
	xor eax, eax
	stosd
	mov eax, ecx
	shl eax, 9
	dec eax
	stosd

	mov dword [rsi+HBA_PxIS], 0
	or dword [rsi+HBA_PxCMD], 10001b
	mov dword [rsi+HBA_PxCI], 1

	.poll:
		mov eax, dword [rsi+HBA_PxCI]
		test eax, eax
	jnz .poll

	and dword [rsi+0x18], 0xFFFFFFEE

	mov edx, dword [rsi+HBA_PxCLBU]
	mov eax, dword [rsi+HBA_PxCLB]
	shl rdx, 32
	or rax, rdx
	mov eax, dword [rax+4]
ret


; rax - LLBA of read start
; rcx - Sectors to read ; assume 4096 sectors for compatibility w NVMe (need testing)
; rdi - destination
; clobs: rax, rcx, rdx, rdi, rsi, r8, r9, rbx
AHCI_read:
	shl rcx, 3
	mov r8, rax
	mov r9, rcx
	mov rbx, rdi

	._loop:
		mov rax, qword [start_LBA]
		add rax, r8 ; starting global sector 

		cmp r9, 8192
		jb .less_8192
			mov rcx, 8192 
		jmp .e_less8192
		.less_8192:
			mov rcx, r9
		.e_less8192:

		mov rdx, qword [AHCI_disk_selected]
		mov rsi, qword [AHCI]
		mov rdi, rbx

		call AHCI_read_sectors
		add rbx, rax
		shr rax, 9
		add r8, rax
		sub r9, rax
	jnz ._loop
	xor rax, rax
ret

; rax - LLBA of read start
; rcx - sectors to write
; rsi - source
AHCI_write:
	shl rcx, 3
	mov r8, rax
	mov r9, rcx
	mov rbx, rsi

	._loop:
		mov rax, qword [start_LBA]
		add rax, r8

		cmp r9, 8192
		jb .less_8192
			mov rcx, 8192
		jmp .e_less8192
		.less_8192:
			mov rcx, r9
		.e_less8192:

		mov rdx, qword [AHCI_disk_selected]
		mov rsi, qword [AHCI]
		mov rdi, rbx

		call AHCI_write_sectors
		add rbx, rax
		shr rax, 9
		add r8, rax
		sub r9, rax
	jnz ._loop
	xor rax, rax
ret

; rsi - AHCI BAR
; rdx - diskn
AHCI_stash_regs:
	shl rdx, 7
	lea rsi, [rsi+rdx+0x100]
	mov edx, dword [rsi+HBA_PxCLB]
	mov dword [PxCLB_stash], edx
	mov edx, dword [rsi+HBA_PxCLBU]
	mov dword [PxCLBU_stash], edx
	mov edx, dword [rsi+HBA_PxFB]
	mov dword [PxFB_stash], edx
	mov edx, dword [rsi+HBA_PxFBU]
	mov dword [PxFBU_stash], edx
ret

; rsi - AHCI BAR
; rdx - diskn
AHCI_restore_regs:
	shl rdx, 7
	lea rsi, [rsi+rdx+0x100]
	mov edx, dword [PxCLB_stash]
	mov dword [rsi+HBA_PxCLB], edx
	mov edx, dword [PxCLBU_stash]
	mov dword [rsi+HBA_PxCLBU], edx
	mov edx, dword [PxFB_stash]
	mov dword [rsi+HBA_PxFB], edx
	mov edx, dword [PxFBU_stash]
	mov dword [rsi+HBA_PxFBU], edx	
ret

; probes all AHCI controllers in the system, with all disks attached to them
; trying to locate a partition of a given name
probe_AHCI:
	cld
	mov rax, 1
	mov rbx, 6
	call PCIe_get_cl_subcl_n
	mov qword [N_AHCI], rax
	mov qword [selected_AHCI], 0

	._loop_1:
		mov rax, 1
		mov rbx, 6
		mov rcx, qword [selected_AHCI]
		call PCIe_get_cl_subcl_adr
		mov qword [AHCI_PCIe], rax ; the controller we will probe
		mov eax, dword [rax+0x24]
		mov qword [AHCI], rax 

		mov rsi, qword [AHCI]
		call AHCI_get_N_disks
		mov qword [AHCI_n_disks], rax
		mov qword [AHCI_diskn], 0

		._loop_2:
			mov rsi, qword [AHCI]
			mov rcx, qword [AHCI_diskn]
			call AHCI_get_disk_id
			mov qword [AHCI_disk_selected], rax

			mov rsi, qword [AHCI]
			mov rdx, qword [AHCI_disk_selected]
			call AHCI_stash_regs

			mov rcx, qword [AHCI_disk_selected]
			mov rdi, qword [AHCI]
			call AHCI_conf_drive

			;mov rax, AHCI_RECV_FIS+0x40
			;mov eax, dword [rax]
			;shr eax, 24
			;jnz ._end_iter_2______

			mov rax, 1
			mov rcx, 1
			mov rdx, qword [AHCI_disk_selected]
			lea rdi, [DISK_ID_BUF]
			mov rsi, qword [AHCI]
			call AHCI_read_sectors

			mov rax, 0x5452415020494645
			cmp rax, qword [DISK_ID_BUF]
			jne ._end_iter_2

			mov rax, qword [DISK_ID_BUF+0x48]
			mov qword [GPT_entry_cur_LBA], rax

			mov eax, dword [DISK_ID_BUF+0x50]
			mov dword [GPT_entry_n], eax

			mov eax, dword [DISK_ID_BUF+0x54]
			mov qword [GPT_entry_sz], rax

			mov eax, dword [GPT_entry_n]
			xor rdx, rdx
			mov rcx, qword [GPT_entry_sz]
			mul ecx
			shr rax, 9
			add rax, qword [GPT_entry_cur_LBA]
			mov qword [GPT_entry_LBA_end], rax

			.read_table:
				mov rax, qword [GPT_entry_cur_LBA]
				mov rcx, 1
				mov rdx, qword [AHCI_disk_selected]
				lea rdi, [DISK_ID_BUF]
				mov rsi, qword [AHCI]
				call AHCI_read_sectors
			;debug_print
			;ret
				xor rbx, rbx
				._loop_3:
					mov rcx, qword [GPT_entry_sz]
					sub rcx, 0x38
					shr rcx, 1
					lea rsi, [DISK_ID_BUF]
					add rsi, rbx
					add rsi, 0x38
					;debug_print
					lea rdi, [partition_name_str]
					repe cmpsw
					test rcx, rcx
					jz .found_partition
					;lea rcx, [DISK_ID_BUF]
					;add rcx, rbx
					;mov rdx, qword [rcx+0x28]
					;mov rcx, qword [rcx+0x20]
					;sub rdx, rcx
					;jz .skip_dbg
					;debug_print_2
					;.skip_dbg:
					add rbx, qword [GPT_entry_sz]
					cmp rbx, 0x200
				jb ._loop_3

				inc qword [GPT_entry_cur_LBA]
				mov rax, qword [GPT_entry_cur_LBA]
				cmp rax, qword [GPT_entry_LBA_end]
			jne .read_table

			._end_iter_2:
			mov rsi, qword [AHCI]
			mov rdx, qword [AHCI_disk_selected]
			call AHCI_restore_regs			
			inc qword [AHCI_diskn]
			mov rax, qword [AHCI_diskn]
			cmp rax, qword [AHCI_n_disks]
		jnz ._loop_2

		inc qword [selected_AHCI]
		mov rax, qword [selected_AHCI]
		cmp rax, qword [N_AHCI]
	jnz ._loop_3

	mov rax, -1
ret
.found_partition:
	lea rax, [DISK_ID_BUF]
	mov rax, qword [rax+rbx+0x20]
	mov qword [start_LBA], rax
	xor rax, rax
ret



