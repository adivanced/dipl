%define NVMe_CAP 0
%define NVMe_VS 8
%define NVMe_INTMS 0xC
%define NVMe_INTMC 0xF
%define NVMe_CC 0x14
%define NVMe_CSTS 0x1C
%define NVMe_NSSR 0x20
%define NVMe_AQA 0x24
%define NVMe_ASQ 0x28
%define NVMe_ACQ 0x30
%define NVMe_CMBLOC 0x38
%define NVMe_CMBSZ 0x3C
%define NVMe_BPINFO 0x40
%define NVMe_BPRSEL 0x44
%define NVMe_BPMBL 0x48
%define NVMe_CMBMSC 0x50
%define NVMe_CMBSTS 0x58
%define NVMe_CMBEBS 0x5C
%define NVMe_CMBSWTP 0x60
%define NVMe_NSSD 0x64
%define NVMe_CRTO 0x68
%define NVMe_PMRCAP 0xE00
%define NVMe_PMRCTL 0xE04
%define NVMe_PMRSTS 0xE08
%define NVMe_PMREBS 0xE0C
%define NVMe_PMRSWTP 0xE10
%define NVMe_PMRMSCL 0xE14
%define NVMe_PMRMSCU 0xE18

%define NVMe_SQ0TDBL 0x1000
%define NVMe_CQ0HDBL 0x1004


%define NVMe_ASQ_BAR 0x170000
%define NVMe_ACQ_BAR 0x171000

%define NVMe_IOSQ_BAR 0x172000
%define NVMe_IOCQ_BAR 0x173000

%define NVMe_CTRLID_BAR 0x174000
%define NVMe_ANS_BAR 0x175000
%define NVMe_NSID_BAR 0x176000
%define NVMe_PRP_BAR 0x177000

; 0xF3987FFB
; F3 98 7F FB

NVMe_mem_prep:
	xor eax, eax
	cld
	mov rdi, NVMe_ASQ_BAR
	mov rcx, 0x200
	rep stosq
	mov rdi, NVMe_ACQ_BAR
	mov rcx, 0x200
	rep stosq
	mov rdi, NVMe_IOSQ_BAR
	mov rcx, 0x200
	rep stosq
	mov rdi, NVMe_IOCQ_BAR
	mov rcx, 0x200
	rep stosq
	mov rdi, NVMe_CTRLID_BAR
	mov rcx, 0x200
	rep stosq
	mov rdi, NVMe_ANS_BAR
	mov rcx, 0x200
	rep stosq
	mov rdi, NVMe_NSID_BAR
	mov rcx, 0x200
	rep stosq
	mov rdi, NVMe_PRP_BAR
	mov rcx, 0x200
	rep stosq
ret


NVMe_init:
	call NVMe_mem_prep

	mov rdi, qword [NVMe_BAR]
	mov rsi, qword [NVMe_PCIe_BAR]
	

	; get nvme irq
	mov eax, dword [rsi+0x3C]
	mov byte [NVMe_IRQ], al

	; enable bus mastering & memory access
	mov eax, dword [rsi+0x4]
	or eax, 0x407 ; disable non msi ints, enable bus mastering, allow mmio&io access
	mov dword [rsi+0x4], eax

	; version check
	mov eax, dword [rdi+NVMe_VS]
	ror eax, 16
	cmp al, 0x1
	jl .init_version_error

	; disable nvme controller
	and dword [rdi+NVMe_CC], 0xFFFFFFFE

	.wait_pre_enable:
		pause
		bt dword [rdi+NVMe_CSTS], 0
	jc .wait_pre_enable

	; configure admin queues (AQA, ASQ, ACQ)
	mov dword [rdi+NVMe_AQA], 0x003F003F ; 64 commands for ACQ and ASQ
	mov rax, NVMe_ASQ_BAR
	mov qword [rdi+NVMe_ASQ], rax
	mov rax, NVMe_ACQ_BAR
	mov qword [rdi+NVMe_ACQ], rax

	; disable controller interrupts
	mov dword [rdi+NVMe_INTMS], 0xFFFFFFFF

	; enable the controller
	mov dword [rdi+NVMe_CC], 0x00460001 ; set IOCQ and IOSQ size, set enable
	.wait_enable:
		pause
		bt dword [rdi+NVMe_CSTS], 1
		jc .error_0
		bt dword [rdi+NVMe_CSTS], 0
	jnc .wait_enable

	; save identify controller structure
	mov eax, 0x00000006
	xor ebx, ebx 
	mov ecx, 0x00000001
	xor edx, edx
	;mov rsi, NVMe_CTRLID_BAR
	;lea rsi, [TMPBUF]
	mov rsi, NVMe_CTRLID_BAR
	call NVMe_admin

	; create IO completion queue
	mov eax, 0x00010005
	xor ebx, ebx
	mov ecx, 0x003F0001
	mov edx, 0x00000001
	mov rsi, NVMe_IOCQ_BAR
	call NVMe_admin

;	eax = cdw0
;	ebx = cdw1
;	ecx = cdw10
;	edx = cdw11
;	rsi = cdw6-7

	; create IO submission queue
	mov eax, 0x00010001
	xor ebx, ebx
	mov ecx, 0x003F0001
	mov edx, 0x00010001
	mov rsi, NVMe_IOSQ_BAR
	call NVMe_admin

	; set active namespace id list
	mov eax, 0x00000006
	xor ebx, ebx
	mov ecx, 0x00000002
	xor edx, edx
	mov rsi, NVMe_ANS_BAR
	call NVMe_admin

	; save identify namespace data
	mov eax, 0x00000006
	mov ebx, 0x00000001
	xor ecx, ecx
	xor edx, edx
	mov rsi, NVMe_NSID_BAR
	call NVMe_admin

	; parse controller identify data
	; serial number (bytes 23-04)
	; model number (bytes 63-24)
	; firmware revision (bytes 71-64)
	; max data transfer size (byte 77)
	; controller ID (bytes 79-78)
[DEFAULT ABS]
	movzx rax, byte [NVMe_CTRLID_BAR+77] ; add check?

	; parse namespace identify data for drive 0
	mov eax, dword [NVMe_NSID_BAR]
	mov dword [NVMe_total_LBA], eax

	; number of LBA formats (NLBAF) byte 25
	; 0 => only 1 format is supported (bytes 131:128)
	; LBA data size (LBADS) (bits 23:16) must be >= 9
	; 9  =>  512 byte sectors
	; 12 =>  4096 byte sectors
	mov ecx, dword [NVMe_NSID_BAR+24]
[DEFAULT REL]
	shr ecx, 16
	inc cl
	mov rsi, NVMe_NSID_BAR+0x80
	xor ebx, ebx
	.init_LBA_next:
		cmp cl, 0
		je .init_LBA_end
		lodsd
		shr eax, 16
		mov bl, al
		cmp al, bl
		jle .init_LBA_skip
		mov bl, al
	.init_LBA_skip:
		dec cl
		jmp .init_LBA_next
	.init_LBA_end:
		mov byte [NVMe_LBA], bl

[DEFAULT ABS]
mov al, byte [NVMe_CTRLID_BAR+77]
[DEFAULT REL]
mov byte [NVMe_max_trans], al
; 	cmp al, bl
; 	jnz .MDTS_unhandled

	xor rax, rax
ret
	.error_0:
	mov rax, -1
ret
	.init_version_error:
	mov rax, -2
	.MDTS_unhandled:
	mov rax, -3
ret


; perform an admin operation on the nvme controller
; args: 
;	eax = cdw0
;	ebx = cdw1
;	ecx = cdw10
;	edx = cdw11
;	rsi = cdw6-7
; ret:
;	nothing
NVMe_admin:
	cld

	push rax
	mov rdi, qword [NVMe_BAR]
	mov rdi, qword [rdi+NVMe_ASQ]

	;xor eax, eax
	movzx rax, byte [NVMe_atail]
	shl rax, 6
	add rdi, rax
	pop rax

	stosd ; cdw0
	mov eax, ebx
	stosd ; cdw1
	xor eax, eax
	stosq ; cdw2-3
	stosq ; cdw4-5
	mov rax, rsi
	stosq ; cdw6-7
	xor eax, eax
	stosq ; cdw8-9
	mov eax, ecx
	stosd ; cdw10
	mov eax, edx
	stosd ; cdw11
	xor eax, eax
	stosq ; cdw12-13
	stosq ; cdw14-15
 

	; start the admin command by updating the tail doorbell
	mov rdi, qword [NVMe_BAR]
	;xor eax, eax
	movzx rax, byte [NVMe_atail]
	inc rax
	cmp rax, 64
	jb .save_tail
	xor rax, rax
	.save_tail:
	mov byte [NVMe_atail], al
	;mov eax, 0
	mov dword [rdi+NVMe_SQ0TDBL], eax

	; check completion queue
	mov rdi, qword [rdi+NVMe_ACQ]
	movzx ecx, byte [NVMe_ahead]
	shl ecx, 4
	lea rdi, [rdi+rcx+12] ; NVMe_ACQ + 16*old_doorbell + 12 = (dw3 of CQ entry)

	.admin_wait:
		pause
		test dword [rdi], 0x00010000 ; check the phase tag 
		;mov eax, dword [rdi] 
		;test eax, 0x00010000 
	jz .admin_wait 
	and dword [rdi], 0xFFFEFFFF ; clear the phase tag

	mov rdi, qword [NVMe_BAR]
	movzx ecx, byte [NVMe_ahead]
	inc ecx
	cmp ecx, 64
	jne .save_head
	xor ecx, ecx
	.save_head:
	mov byte [NVMe_ahead], cl
	mov dword [rdi+NVMe_CQ0HDBL], ecx ; update the ACQ head doorbell

ret

; perform an io operation on nvme device
; args:
;	rax = starting sector
;	rbx = io opcode
;	rcx = N sectors ; caller assumes 4096 byte sectors, callee does all size conversions transparent to the caller. 
;	rdx = drive #
;	rdi = memory ptr
NVMe_io:
	cld
	inc rdx ; disk id starts at 1 not 0

	test rcx, rcx
	jz .error_0 ; no data requested

	cmp byte [NVMe_LBA], 0x0C
	jz .setup
	cmp byte [NVMe_LBA], 0x09
	jnz .error_1 ; unknown LBA size

	.convert_512:
		shl rcx, 3
		shl rax, 3

	.setup:
	mov rsi, rdi
	movzx edi, byte [NVMe_iotail]
	shl rdi, 6
	add rdi, NVMe_IOSQ_BAR

	xchg rax, rbx
	stosd ; CDW0 - opcode
	mov eax, edx
	stosd ; CDW1 - NSID
	xor rax, rax
	stosq ; CDW2-3 - cmd specific
	stosq ; CDW4-5 - metadata ptr (none)
	mov rax, rsi
	stosq ; CDW6-7 - PRP1
	add rax, 4096 ; next PRP
	push rcx ; save data transfer count
	dec rcx ; amount of 4096 blocks not handled by PRP1
	cmp rcx, 1
	jb .skip_PRP2
	je .singular_PRP2
	push rdi
	push rcx
	xor eax, eax
	mov rdi, NVMe_PRP_BAR
	mov rcx, 0x200
	rep stosq ; clear PRP list
	pop rcx
	pop rdi
	mov rax, NVMe_PRP_BAR
	stosq ; CDW8-9 - PRP2
	add rsi, 4096 ; prepare PRP2 address
	.PRP2_loop:
		mov qword [rax], rsi
		add rsi, 4096
		dec rcx
	jnz .PRP2_loop
	.PRP2_end:
	mov rax, rbx 
	stosq ; CDW10-11 - SLBA (separate dwords mb?)
	pop rax
	dec eax
	stosd ; CDW12 - number of blocks -1
	xor eax, eax
	stosd ; CDW13
	stosq ; CDW14-15

	mov rdi, qword [NVMe_BAR]
	movzx eax, byte [NVMe_iotail]
	mov ecx, eax ; stash old tail value
	inc al
	cmp al, 64
	jb .save_tail
	xor eax, eax
	.save_tail:
	mov byte [NVMe_iotail], al
	mov dword [rdi+0x1008], eax

	mov rsi, NVMe_IOCQ_BAR
	shl ecx, 4
	lea rsi, [rsi+rcx+12]
	.io_wait:
		pause
		test dword [rsi], 0x00010000
	jz .io_wait
	and dword [rsi], 0xFFFEFFFF ; clear phase tag

	mov dword [rdi+0x100C], eax
	xor eax, eax
ret

.skip_PRP2:
	xor rax, rax
	stosq ; CDW8-9 - PRP2
jmp .PRP2_end

.singular_PRP2:
	stosq ; CDW8-9 - PRP2
jmp .PRP2_end

.error_0:
	mov rax, -1 ; no data req
ret
.error_1:
	mov rax, -2 ; unknown LBA size
ret



; perform an io operation on nvme device
; args:
;	rax = starting sector
;	rbx = io opcode
;	rcx = N sectors ; caller assumes 4096 byte sectors, callee does all size conversions transparent to the caller. 
;	rdx = drive #
;	rdi = memory ptr
; NVMe_io_old:
; 	push rdi
; 	push rcx
; 	push rbx
	
; 	add rdx, 1 ; disk № starts at 1, not 0

; 	test rcx, rcx
; 	jz .error_0 ; no data requested

; 	; check sector size
; 	cmp byte [NVMe_LBA], 0x0C ; 4096 byte sectors
; 	jz .setup
; 	cmp byte [NVMe_LBA], 0x09 ; 512 byte sectors
; 	jnz .error_0 ; unknown LBA size

; 	; convert 512 sector size
; 	.convert_512:
; 		shl rcx, 3 
; 		shl rax, 3 

; 	; create I/O entry
; 	.setup:

; 		push rax
; 		push rbx
; 		mov rbx, rdi

; 		xor edi, edi
; 		mov byte dil, [NVMe_iotail]
; 		shl rdi, 6
; 		add rdi, NVMe_IOSQ_BAR
; 		cld

; 		; 64-byte command
; 		pop rax
; 		and eax, 0xFF
; 		stosd ; CDW0 CID (31:16), PRP used (15:14 clear), FUSE normal (bits 9:8 clear), command ()
; 		mov eax, edx
; 		stosd ; CDW1 NSID
; 		xor eax, eax
; 		stosq ; CDW2-3 ELBST EILBRT (47:00)
; 		stosq ; CDW4-5 MPTR
; 		mov rax, rbx
; 		stosq ; CDW6-7 PRP1

; 		; calculate PRP2
; 		; For 1 - 4096 bytes only PRP1 is needed, PRP2 is ignored
; 		; For 4097 - 8192 bytes PRP2 is needed to point to memory address to store it
; 		; For 8193+ bytes PRP2 points to a list of more PRPs 
; 		push rcx
; 		cmp rcx, 2
; 		jbe .prp2_skip
; 		dec rcx
; 		push rdi
; 		mov rdi, NVMe_PRP_BAR
; 		.next_prp:
; 			add rax, 4096
; 			stosq
; 			dec rcx
; 		jnz .next_prp
; 		pop rdi
; 		mov rax, NVMe_PRP_BAR
; 		jmp .prp2_end
; 		.prp2_skip:
; 			add rax, 4096
; 		.prp2_end:
; 		stosq ; CDW8-9 PRP2
; 		pop rcx
; 		pop rax
; 		stosd ; CDW10 SLBA (31:00)
; 		shr rax, 32
; 		stosd ; CDW11 SLBA (63:32)
; 		lea rax, [rcx-1]
; 		stosd ; CDW12 Number of Logical Blocks (15:00)
; 		xor eax, eax
; 		stosd
; 		stosd
; 		stosd

; 		; Start the I/O command by updating the tail doorbell
; 		mov rdi, qword [NVMe_BAR]
; 		movzx eax, byte [NVMe_iotail]
; 		mov ecx, eax
; 		inc al
; 		cmp al, 64
; 		jl .save_tail
; 		xor eax, eax
; 		.save_tail:
; 		mov byte [NVMe_iotail], al ; Save the tail for the next command
; 		mov dword [rdi+0x1008], eax ; Write the new tail value

; 		;check completion queue
; 		mov rdi, NVMe_IOCQ_BAR
; 		shl rcx, 4
; 		lea rdi, [rdi+rcx+12]
		
; 		.io_wait:
; 			pause
; 			test dword [rdi], 0x00010000
; 			; mov rax, qword [rdi]
; 			; test rax, rax
; 		jz .io_wait
; 		and dword [rdi], 0xFFFEFFFF

; 		.io_done:
; 			sub rdx, 1
; 			pop rbx
; 			pop rcx
; 			pop rdi
; 		ret
; .error_0:
; 	sub rdx, 1
; 	pop rbx
; 	pop rcx
; 	pop rdi
; 	xor rcx, rcx
; ret

; rsi - NVMe BAR
NVMe_stash_regs:
	mov eax, dword [rsi+NVMe_AQA]
	mov dword [NVMe_AQA_stash], eax
	mov rax, qword [rsi+NVMe_ASQ]
	mov qword [NVMe_ASQ_stash], rax
	mov rax, qword [rsi+NVMe_ACQ]
	mov qword [NVMe_ACQ_stash], rax
ret

; rsi - NVMe BAR
NVMe_restore_regs:
	mov eax, dword [NVMe_AQA_stash]
	mov dword [rsi+NVMe_AQA], eax
	mov rax, qword [NVMe_ASQ_stash]
	mov qword [rsi+NVMe_ASQ], rax
	mov rax, qword [NVMe_ACQ_stash]
	mov qword [rsi+NVMe_ACQ], rax
ret

; rsi - NVMe BAR
NVMe_disable:
	and dword [rsi+NVMe_CC], 0xFFFFFFFE

	.wait_pre_enable:
		pause
		bt dword [rsi+NVMe_CSTS], 0
	jc .wait_pre_enable	
ret

NVMe_reset_vars:
	mov byte [NVMe_IRQ], 0
	mov dword [NVMe_total_LBA], 0
	mov byte [NVMe_LBA], 0
	mov byte [NVMe_atail], 0
	mov byte [NVMe_ahead], 0
	mov byte [NVMe_iotail], 0
	mov byte [NVMe_iohead], 0	

	mov qword [GPT_entry_LBA_end], 0
	mov qword [GPT_entry_cur_LBA], 0
	mov dword [GPT_entry_n], 0
	mov qword [GPT_entry_sz], 0

ret

; probes all NVMe controllers in the system, trying to locate a partition of a given name
probe_NVMe:
	cld
	mov rax, 1
	mov rbx, 8
	call PCIe_get_cl_subcl_n
	mov qword [NVMe_n], rax
	mov qword [NVMe_cur], 0

	._loop1:
		mov rax, 1
		mov rbx, 8
		mov rcx, qword [NVMe_cur]
		call PCIe_get_cl_subcl_adr
		mov qword [NVMe_PCIe_BAR], rax
		mov ebx, dword [rax+0x10]
		mov eax, dword [rax+0x14]
		shl rax, 32
		or rax, rbx
		and rax, 0xFFFFFFFFFFFFFFF0
		mov qword [NVMe_BAR], rax

		call NVMe_stash_regs

		call NVMe_init
		cmp rax, 0
		jne .not_GPT

		mov rax, 0
		mov rbx, 2
		mov rcx, 1
		mov rdx, 0
		mov rdi, 0x178000 ; read GPT partition
		call NVMe_io

[DEFAULT ABS]
		mov rax, 0x5452415020494645
		cmp qword [0x178200], rax
		jnz .not_GPT

		mov rax, qword [0x178248]
[DEFAULT REL]		
		mov qword [GPT_entry_cur_LBA], rax
[DEFAULT ABS]		
		mov eax, dword [0x178250]
[DEFAULT REL]		
		mov dword [GPT_entry_n], eax
[DEFAULT ABS]		
		mov eax, dword [0x178254]
[DEFAULT REL]		
		mov dword [GPT_entry_sz], eax

		mov rbp, 0x178000
		mov rbx, qword [GPT_entry_cur_LBA]
		shl rbx, 9
		add rbp, rbx ; start of the GPT entries array
		xor rbx, rbx
		._loop2:
			mov rcx, qword [GPT_entry_sz]
			sub rcx, 0x38
			shr rcx, 1
			lea rsi, [rbp+0x38]		
			lea rdi, [partition_name_str]
			repe cmpsw
			test rcx, rcx
			jz .found_partition
			add rbp, qword [GPT_entry_sz]
			inc rbx
			cmp ebx, dword [GPT_entry_n]
		jb ._loop2

		.not_GPT:
		mov rsi, qword [NVMe_BAR]
		call NVMe_disable
		call NVMe_restore_regs
		call NVMe_reset_vars
		mov rax, qword [NVMe_cur]
		inc rax
		mov qword [NVMe_cur], rax
		cmp rax, qword [NVMe_n]
	jnz ._loop1

	mov rax, -1 ; could not find a fitting NVMe drive
ret

.found_partition:
	mov rax, qword [rbp+0x20]
	mov qword [start_LBA], rax
	xor rax, rax
ret

; rax - LLBA of read start, assume 512, but align by 4096
; rcx - Sectors to read, assume 4096
; rdi - dest
NVMe_read: ; needs extensive testing!!!!!
	mov rbx, qword [start_LBA]
	;shr rbx, 3 ; convert GPT's 512 byte units to 4096 byte units
	add rax, rbx
	shr rax, 3 ; convert address to 4096 sectors
	cmp byte [NVMe_max_trans], 0
	je .no_limit


	push rax ; LBA of read
	push rdi ; destination 
	push rcx ; sectors left to read

	mov rbx, 1
	mov cl, byte [NVMe_max_trans] ; get the max size
	shl rbx, cl
	mov rcx, qword [rsp]
	cmp rbx, rcx
	jb .limit
	add rsp, 24
	jmp .no_limit

	.limit:
	push rbx ; read limit
	._loop:
		mov rax, qword [rsp-24] ; get LBA of start read
		mov rbx, rax
		add rbx, qword [rsp] ; move read LBA to the right
		mov qword [rsp-24], rbx
		mov rdi, qword [rsp-16] ; get dest
		mov rbx, qword [rsp] ; get limit
		shl rbx, 12 ; sectors to bytes
		add rbx, rdi ; move dest address to the right
		mov qword [rsp-16], rbx

		mov rcx, qword [rsp-8] ; left to read
		mov rbx, qword [rsp] ; limit
		cmp rcx, rbx
		jbe .no_limit_p
		sub rcx, rbx
		mov qword [rsp-8], rcx
		mov rcx, rbx
		
		mov rbx, 2
		mov rdx, 0
		call NVMe_io
		cmp qword [rsp-8], 0
	jg ._loop
	add rsp, 32
ret

	.no_limit_p:
	add rsp, 32
	.no_limit:
	mov rbx, 2
	mov rdx, 0
	call NVMe_io
	.end:
ret

; rax - LLBA of read start, assume 512 but align by 4096
; rcx - Sectors to read, assume 4096
; rsi - dest
NVMe_write:
	mov rbx, qword [start_LBA]
;	shr rbx, 3 ; convert GPT's 512 byte units to 4096 byte units
	add rax, rbx
	shr rax, 3
	cmp byte [NVMe_max_trans], 0
	je .no_limit


	push rax ; LBA of read
	push rdi ; destination 
	push rcx ; sectors left to read

	mov rbx, 1
	mov cl, byte [NVMe_max_trans] ; get the max size
	shl rbx, cl
	mov rcx, qword [rsp]
	cmp rbx, rcx
	jb .limit
	add rsp, 24
	jmp .no_limit

	.limit:
	push rbx ; read limit
	._loop:
		mov rax, qword [rsp-24] ; get LBA of start read
		mov rbx, rax
		add rbx, qword [rsp] ; move read LBA to the right
		mov qword [rsp-24], rbx
		mov rdi, qword [rsp-16] ; get dest
		mov rbx, qword [rsp] ; get limit
		shl rbx, 12 ; sectors to bytes
		add rbx, rdi ; move dest address to the right
		mov qword [rsp-16], rbx

		mov rcx, qword [rsp-8] ; left to read
		mov rbx, qword [rsp] ; limit
		cmp rcx, rbx
		jbe .no_limit_p
		sub rcx, rbx
		mov qword [rsp-8], rcx
		mov rcx, rbx
		
		mov rbx, 1
		mov rdx, 0
		call NVMe_io
		cmp qword [rsp-8], 0
	jg ._loop
	add rsp, 32
ret

	.no_limit_p:
	add rsp, 32
	.no_limit:
	mov rbx, 1
	mov rdx, 0
	call NVMe_io
	.end:
ret
