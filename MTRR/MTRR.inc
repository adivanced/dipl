; stores the amount and avalibility of dynamic MTRRs into inner vars
; returns -1 if no dynamic MTRR's found
init_MTRR:
	mov qword [dyn_MTRR_avalible], 0

	mov ecx, 0xFE
	rdmsr
	shl rdx, 32
	or rax, rdx
	and rax, 0xFF
	mov qword [dyn_MTRR_avalible], rax

	xor rax, rax
ret

;  MTRR_MASK = ~(size_of_range) !!!!

; returns the BASE dynamic MTRR MSR №
; returns -1 on error or if MTRRs unavalible
get_vacant_MTRR:
	cmp qword [dyn_MTRR_avalible], 0
	jz .error

	mov rdi, 0x201
	._loop:
		mov ecx, edi
		rdmsr
		shl rdx, 32
		or rax, rdx
		test rax, 0x800
		jz .found
		add rdi, 2
		inc rbx
		cmp rbx, qword [dyn_MTRR_avalible]
	jnz ._loop

	.error:
	mov rax, -1
ret

.found:
	lea rax, [rdi-1]
ret


; rax - mtrr_base id
; rbx - region BAR
; rcx - region size
; rdx - memory type
; rdi - address size in bits (39 for me)
set_MTRR_pair:
	mov rsi, rdi
	xor rdi, rdi
	bts rdi, rsi
	dec rdi 
	and rdi, 0xFFFFFFFFFFFFF000 ; get the mask for address and mask

	mov rsi, rdi
	not rsi 
	test rbx, rsi
	jnz ._error_1 ; (?)

	and rdx, 0xFF 

	neg rcx ; get the mask (probably) (?)
	and rcx, rdi

	push rcx
	push rdx
	mov ecx, eax

	rdmsr
	shl rdx, 32
	or rax, rdx ; rax - mtrr_base_n
	and rax, rdi
	or rax, rbx
	or rax, qword [rsp]
	mov rdx, rax
	shr rdx, 32
	wrmsr

	inc ecx
	rdmsr
	shl rdx, 32
	or rax, rdx ; rax - mtrr_mask_n
	and rax, rdi
	or rax, qword [rsp+8]
	bts rax, 11
	mov rdx, rax
	shr rdx, 32
	wrmsr

	add rsp, 16
ret

._error_1:
	mov rax, -1
ret