[BITS 64]
[DEFAULT REL]


; rax - desired frequency
; rbx - interrupt vector
; rcx - timerN
; rdx - intN
init_hpet:
	cli
	push rdx
	push rcx
	push rax
	push rdx
	push rbx	
	call get_ACPI_HPET_BAR
	cmp rax, -1
	je .error_1
	cmp rax, -2
	je .error_2
	cmp rax, -3
	je .error_3
;============Cofigure=IDT=========================
	; at this point: rax - free, rbx - timN int route, rcx - timN offset, rdx - free
	pop rcx ; ISR handler
	xchg qword [rsp], rax
	mov bx, cs
	xor dl, dl ; no interrupt stack table
	mov dh, 0x8E ; int gate, 0 pri, present(???)
	call write_IDT_gate
	; timN routing - on stack
;=================================================

;============Cofigure=HPET========================
	;mov r9, rax
	pop r9
	mov rax, r9
	mov r8, qword [rax+44] ; HPET MMIO BAR
	mov qword [HPET], r8

	mov rbx, qword [r8]
	shr rbx, 32

	mov rax, qword [.var10pow15]
	xor rdx, rdx
	div rbx ; timer frequency

	pop rbx
	xor rdx, rdx
	div rbx ; timer frequency/desired frequency = comparator value in rax

	xor rbx, rbx
	mov bx, word [r9+53]
	cmp rax, rbx
	jb .error_4 ; desired frequency not implemented

	pop rcx
	shl rcx, 5 ; timerN offset

	test qword [r8+rcx+0x100], 0x20
	jz .error_5 ; no 64-bit mode

	test qword [r8+rcx+0x100], 0x10
	jz .error_6 ; no periodic mode

	test qword [r8+rcx+0x100], 0x8000
	jz .error_7 ; no FSB routing

	mov qword [r8+0x10], 0 ; disable legacy interrupt mapping, halt HPET


	btr qword [r8+rcx+0x100], 2 ; disable timer
	btr qword [r8+rcx+0x100], 1 ; set edge triggered mode

	; mask for timN conf reg: 1 << 2 (enable ints) | 1 << 3 (periodic) | 1 << 6 (some stuff bout comparators acc) | 1 << 14 Enable FSB mapping
	;or qword [r8+rcx+0x100], (1<<2) | (1<<3) | (1<<6) | (1<<14)
	or qword [r8+rcx+0x100], (1<<3) | (1<<6) ; periodic | some stuff bout comparators acc

	mov qword [r8+rcx+0x108], rax ; save comparator
	mov qword [r8+0xF0], 0 ; main counter value - 0

	
	mov rax, [lapic]
	mov edx, dword [rax+0x20]
	shl edx, 12
	or rax, rdx
	bts rax, 3
	btr rax, 2
	shl rax, 32
	or rax, qword [rsp] ; high dword - "lapic" addr, low dword - INTn
	add rsp, 8
	and rax, 0xFFFFFFFFFFFF78FF ; some other configurations (vol 3 intel programming manual)
	mov qword [r8+rcx+0x110], rax 

;=================================================
	or qword [r8+rcx+0x100], (1<<2)|(1<<14) ; enable ints | enable FSB mapping

	or qword [r8+0x10], 1

	xor rax, rax
ret


.error_1:
.error_2:
.error_3:
add rsp, 40
ret
.error_4:
add rsp, 16
mov rax, -4
ret
.error_5:
add rsp, 8
mov rax, -5
ret
.error_6:
add rsp, 8
mov rax, -6
ret
.error_7:
add rsp, 8
mov rax, -7
ret

.var10pow15 dq 1000000000000000
			 ; 10000000
			 ; 100000000 hz

%include "../HPET/HPET.inc"
%include "../apic/apic.inc"
%include "../IDT/IDT.inc"


; 0x00989680


;Intel® 64 and IA-32 Architectures Software Developer's Manual Volume 3 (3A, 3B & 3C), System Programming Guide