init_hpet_wrapper:
	push rbx
	push rbp
	push r12
	push r13
	push r14
	push r15
	push rcx
	push rdx
	push rsi
	push rdi
	pop rax
	pop rbx
	pop rcx
	pop rdx
	call init_hpet

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	pop rbx
ret
print_func_wrapper:
	push rbx
	push rbp
	push r12
	push r13
	push r14
	push r15
	push rdi
	pop rax
	call print_func

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	pop rbx
ret
cvt2hex_wrapper:
	push rbx
	push rbp
	push r12
	push r13
	push r14
	push r15
	push rsi
	push rdi
	pop rdi
	pop rax
	call cvt2hex

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	pop rbx
ret
get_MADT_BAR_wrapper:
	push rbx
	push rbp
	push r12
	push r13
	push r14
	push r15
	call get_MADT_BAR

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	pop rbx
ret
conf_LAPIC_wrapper:
	push rbx
	push rbp
	push r12
	push r13
	push r14
	push r15
	call conf_LAPIC

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	pop rbx
ret
disable_PIC_wrapper:
	push rbx
	push rbp
	push r12
	push r13
	push r14
	push r15
	call disable_PIC

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	pop rbx
ret
exportfunc_fill:
	lea rax, [EFI_SYSTEM_TABLE]
	mov qword [EFI_SYSTEM_TABLE_wrapptr], rax

	lea rax, [intfunc]
	mov qword [intfunc_wrapptr], rax

	lea rax, [counter]
	mov qword [counter_wrapptr], rax

	lea rax, [init_hpet_wrapper]
	mov qword [init_hpet_wrapper_wrapptr], rax

	lea rax, [print_func_wrapper]
	mov qword [print_func_wrapper_wrapptr], rax

	lea rax, [tststr]
	mov qword [tststr_wrapptr], rax

	lea rax, [cvt2hex_wrapper]
	mov qword [cvt2hex_wrapper_wrapptr], rax

	lea rax, [get_MADT_BAR_wrapper]
	mov qword [get_MADT_BAR_wrapper_wrapptr], rax

	lea rax, [conf_LAPIC_wrapper]
	mov qword [conf_LAPIC_wrapper_wrapptr], rax

	lea rax, [disable_PIC_wrapper]
	mov qword [disable_PIC_wrapper_wrapptr], rax

ret

