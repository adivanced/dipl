[BITS 64]
[DEFAULT REL]


; rax - desired frequency
; rbx - interrupt vector
; rcx - timerN
; rdx - intN
init_hpet:
	cli
	push rdx
	push rbx
	push rcx
	push rax
	call get_ACPI_HPET_BAR
	cmp rax, -1
	je .error_1
	cmp rax, -2
	je .error_2
	cmp rax, -3
	je .error_3

;============Cofigure=HPET========================
	mov r9, rax
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

	;and qword [r8+0x10], 1 ; disable legacy interrupt mapping
	mov qword [r8+0x10], 0 ; disable legacy interrupt mapping, halt HPET


	mov rdx, 0x4006 ; disable FSB int mapping, disable timer0, set edge triggered
	not rdx
	and qword [r8+rcx+0x100], rdx 

	mov rbx, qword [r8+rcx+0x100]
	shr rbx, 32
	bsf rbx, rbx ; timerN interrupt routing

	; mask for timN conf reg: timN_int << 9 | 1 << 2 (enable ints) | 1 << 3 (periodic) | 1 << 6 (some stuff bout comparators acc)
	mov rdx, rbx
	shl rdx, 9
	or rdx, (1<<2) | (1 << 3) | (1 << 6)
	or qword [r8+rcx+0x100], rdx

	mov qword [r8+rcx+0x108], rax ; save comparator
	mov qword [r8+0xF0], 0 ; main counter value - 0 
;=================================================

;============Cofigure=IDT=========================
	; at this point: rax - free, rbx - timN int route, rcx - timN offset, rdx - free
	pop rcx ; ISR handler
	mov rax, qword [rsp] ; INTn
	push rbx ; save timN routing
	mov bx, cs
	xor dl, dl ; no interrupt stack table
	mov dh, 0x8E ; int gate, 0 pri, present(???)
	call write_IDT_gate
	; timN routing - on stack
;=================================================

;============Disable=8259PICs=====================
	call disable_PIC
;=================================================

;============Cofigure=LAPIC=======================
	call conf_LAPIC
;=================================================

;============Cofigure=IOAPIC======================
	; Wee need to determine the IOAPIC id that corresponds to the selected IRQ
	pop rax
	call get_ioapic_id_offs

	mov qword [io_apic], rax
	mov dword [io_apic_index], edx ; debug

	mov dword [rax], edx ; select low dword of IOREDTBLN

	; clear place for 0x22, edge trig, high, physdest, enabled, FIXED delivery type
	pop rdx ; get INTn
	or edx, 10000000000000b ; say low active polarity
	mov dword [rax+0x10], edx 

	inc dword [rax] ; select high dword of IOREDTBLN

	mov rdx, qword [lapic]
	mov edx, dword [rdx+0x20]
	shl edx, 24
	mov dword [rax+0x10], edx
;=================================================

	mov rax, qword [r8+0x10]
	or rax, 1
	mov qword [r8+0x10], rax
	xor rax, rax
ret


.error_1:
.error_2:
.error_3:
ret
.error_4:
add rsp, 24
mov rax, -4
ret
.error_5:
add rsp, 16
mov rax, -5
ret
.error_6:
add rsp, 16
mov rax, -6
ret

.var10pow15 dq 1000000000000000
			 ; 10000000
			 ; 100000000 hz

%include "../HPET/HPET.inc"
%include "../apic/apic.inc"
%include "../IDT/IDT.inc"


; 0x00989680