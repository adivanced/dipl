[BITS 64]
[DEFAULT REL]

; TODO sometime later: multi PCIe detection


; No args (implicit - need global variables EFI_SYSTEM_TABLE, RSDP, MCFG, XSDT)
; return values - rax - E-conf-space BAR, edx - {(uint16_t)Segment group number, (uint8_t)Start bus number, (uint8_t)End bus number}
; return upon error - 1 if could not locate RSDP, 2 if could not get XSDT, 3 if could not locate MCFG
align 8
get_PCIe_BAR:  
	.find_rsdp:
		mov rax, qword [EFI_SYSTEM_TABLE]
		mov rdi, qword [rax+112]
		mov rdx, qword [rax+104]

		xor rax, rax
		cld

		.findloop_RSDP:
			lea rsi, [.RSDP_GUID_analytic_2]
			mov rcx, 16
			repe cmpsb
			jz .equal

			lea rdi, [rdi+rcx+8]
			inc rax
			cmp rax, rdx
		jnz .findloop_RSDP

		jmp .end_1
		.equal:
			mov rdi, qword [rdi]
			mov qword [RSDP], rdi

	mov rcx, qword [RSDP]
	mov rcx, qword [rcx+24]
	mov qword [XSDT], rcx
	cmp dword [rcx], 'TDSX'
	jz .end_2


	.find_MCFG:
		mov rdi, qword [XSDT]
		mov edx, dword [rdi+4] ; xsdt size
		sub edx, 36 
		shr edx, 3 ; number of entries
		add rdi, 36

		mov ecx, 'MCFG'				
		xor rax, rax

		.findloop_MCFG:
			mov rsi, qword [rdi+rax*8]	
			; mov ebx, dword [rsi]
			; mov dword [array+rax*4], ebx
			cmp ecx, dword [rsi]
			jz .equal_MCFG

			;add rdi, 8
			inc rax
			cmp rax, rdx
		jnz .findloop_MCFG

	jmp .end_3
	.equal_MCFG:
		mov qword [MCFG], rsi

	mov eax, dword [rsi+4] ; get the total length of MCFG
	sub rax, 44 ; get the size of the segment group descriptor array
	shr rax, 4  ; get the amount of segment groups

	mov qword [PICe_segn], rax

	xor rdx, rdx
	add rsi, 44
	.segm_loop:
		mov rcx, qword [rsi] ; get BAR
		shl rdx, 4
		lea rdi, [PCIe_BAR_array]
		mov qword [rdi+rdx], rcx
		mov ecx, dword [rsi+8]
		lea rdi, [PCIe_border_array]
		mov qword [rdi+rdx], rcx
		add rsi, 16
		shr rdx, 4
		inc rdx
		cmp rdx, rax
	jb .segm_loop

	xor rax, rax
ret
	
	.end_3:
	mov rax, 3
ret
	.end_2:
	mov rax, 2
ret
	.end_1:
	mov rax, 1
ret
.RSDP_GUID_analytic_2 db 0x71, 0xe8, 0x68, 0x88, 0xf1, 0xe4, 0xd3, 0x11, 0xbc, 0x22, 0x00, 0x80, 0xc7, 0x3c, 0x88, 0x81

; returns the number of PCIe controllers
get_n_PCIe:
	mov rax, qword [MCFG]
	mov eax, dword [rax+4]
	sub rax, 44 ; length - header size
	shr rax, 4 
ret




; rax - PCIe bar
; rbx - bus
; rcx - device
; rdx - function
; returns device BAR
PCIe_get_device_offs:
	;sub rbx, qword [PCIe_stbsn]
	shl rbx, 20 ; bus *= 256 * 4096
	shl rcx, 15 ; device *= 8 * 4096
	shl rdx, 12 ; function *= 4096
	add rax, rbx
	add rax, rcx
	add rax, rdx
ret

; rax - device class
; rbx - device subclass
PCIe_get_cl_subcl_n:
	xor r8, r8 ; counter for found devices
	xor rdx, rdx ; the segment iterator
	._segment_loop:
		lea rsi, [PCIe_BAR_array]
		mov rsi, qword [rsi+rdx*8]
		lea rcx, [PCIe_border_array]
		xor rdi, rdi
		mov dil, byte [rcx+rdx*8+3]
		mov cl, byte [rcx+rdx*8+2]
		and ecx, 0xFF
		sub rdi, rcx ; substract to use end bus number as a counter
		shl rcx, 20
		add rsi, rcx ; move the current PCIe BAR to the starting bus position for searching 
		._search_loop:
			mov r9, 32 ; device max counter for the bus
			._dev_loop:
				mov r10, 8 ; function max counter for the device
				._func_loop:
					mov ecx, dword [rsi+0x8] ; get the PCIe reg, containing the class and subclass
					shr ecx, 24 ; isolate dev class
					cmp eax, ecx
					jz ._equal
					.e_equal:
					add rsi, 4096
					dec r10
				jnz ._func_loop
				dec r9
			jnz ._dev_loop
			dec rdi
		jnz ._search_loop
		inc rdx
		cmp rdx, qword [PICe_segn]
	jb ._segment_loop
	mov rax, r8
ret

._equal:
	mov ecx, dword [rsi+0x8]
	shr ecx, 16
	and ecx, 0xFF ; isolate dev subclass
	cmp ecx, ebx
	jnz .e_equal
	inc r8
jmp .e_equal



; rax - dev class
; rbx - dev subclass
; rcx - dev N
; returns Nth device's address with given class and subclass
PCIe_get_cl_subcl_adr:
	mov rbp, rcx ; stash the counter
	xor r8, r8 ; counter for found devices
	xor rdx, rdx ; the segment iterator
	._segment_loop:
		lea rsi, [PCIe_BAR_array]
		mov rsi, qword [rsi+rdx*8]
		lea rcx, [PCIe_border_array]
		xor rdi, rdi
		mov dil, byte [rcx+rdx*8+3]
		mov cl, byte [rcx+rdx*8+2]
		and ecx, 0xFF
		sub rdi, rcx ; substract to use end bus number as a counter
		shl rcx, 20
		add rsi, rcx ; move the current PCIe BAR to the starting bus position for searching 
		._search_loop:
			mov r9, 32 ; device max counter for the bus
			._dev_loop:
				mov r10, 8 ; function max counter for the device
				._func_loop:
					mov ecx, dword [rsi+0x8] ; get the PCIe reg, containing the class and subclass
					shr ecx, 24 ; isolate dev class
					cmp eax, ecx
					jz ._equal
					.e_equal:
					add rsi, 4096
					dec r10
				jnz ._func_loop
				dec r9
			jnz ._dev_loop
			dec rdi
		jnz ._search_loop
		inc rdx
		cmp rdx, qword [PICe_segn]
	jb ._segment_loop
	mov rax, -1
ret

._equal:
	mov ecx, dword [rsi+0x8]
	shr ecx, 16
	and ecx, 0xFF ; isolate dev subclass
	cmp ecx, ebx
	jnz .e_equal
	cmp r8, rbp
	jz .found
	inc r8
jmp .e_equal

.found:
	mov rax, rsi
ret







; ; rax - dev class
; ; rbx - dev subclass
; ; returns the amount of devices with given class and subclass
; PCIe_get_cl_subcl_n:
; 	;mov rdi, qword [PCIe]
; 	;mov rdx, qword [PCIe_enbsn]
; 	;sub rdx, qword [PCIe_stbsn]
; 	shl rdx, 20
; 	lea rdx, [rdi+rdx]
; 	add rdx, 0x1F << 15
; 	add rdx, 0x7 << 12
; 	xor ecx, ecx
; 	._loop:
; 		mov esi, dword [rdi+0x8]
; 		shr esi, 24
; 		cmp eax, esi
; 		jz .equal
; 		.e_equal:
; 		add rdi, 4096
; 		cmp rdi, rdx
; 	jb ._loop
; 	mov rax, rcx
; ret
; .equal:
; 	mov esi, dword [rdi+0x8]
; 	shr esi, 16
; 	and esi, 0xFF
; 	cmp ebx, esi
; 	jnz .e_equal
; 	inc ecx
; jmp .e_equal


; ; rax - dev class
; ; rbx - dev subclass
; ; rcx - dev N
; ; returns Nth device's address with given class and subclass
; PCIe_get_cl_subcl_adr:
; 	;mov rdi, qword [PCIe]
; 	;mov rdx, qword [PCIe_enbsn]
; 	;sub rdx, qword [PCIe_stbsn]
; 	shl rdx, 20
; 	lea rdx, [rdi+rdx]
; 	add rdx, 0x1F << 15
; 	add rdx, 0x7 << 12
; 	xor ebp, ebp
; 	._loop:
; 		mov esi, dword [rdi+0x8]
; 		shr esi, 24
; 		cmp eax, esi
; 		jz .equal
; 		.e_equal:
; 		add rdi, 4096
; 		cmp rdi, rdx
; 	jb ._loop
; 	mov rax, -1
; ret
; .equal:
; 	mov esi, dword [rdi+0x8]
; 	shr esi, 16
; 	and esi, 0xFF
; 	cmp ebx, esi
; 	jnz .e_equal
; 	cmp ecx, ebp
; 	jz .end
; 	inc ebp
; jmp .e_equal

; .end:
; 	mov rax, rdi
; ret
