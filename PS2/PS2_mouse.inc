%macro set_mouse_sample 1
	mov al, 0xD4
	out 0x64, al
	mov al, 0xF3
	out 0x60, al
	%%_loop:
		pause
		in al, 0x64
		test al, 1
	jz %%_loop
	in al, 0x60 ; ack byte
	mov al, 0xD4
	out 0x64, al
	mov al, %1
	out 0x60, al
	%%_loop_2:
		pause
		in al, 0x64
		test al, 1
	jz %%_loop_2
	in al, 0x60 ; this should hopefully set the mouse sample rate (hopefully)
%endmacro 

PS2_mouse_init:
	set_mouse_sample 100
	set_mouse_sample 200
	set_mouse_sample 80
ret


PS2_mouse_IRQ_4bytes:
	push rax
	push rbx
	inc qword [mos_cnt]

	in al, 0x60
	lea rbx, [mouse_packet]
	add rbx, qword [mouse_byte_recv]
	mov byte [rbx], al
	inc qword [mouse_byte_recv]
	cmp qword [mouse_byte_recv], 4
	jb .end

	mov qword [mouse_byte_recv], 0

	movzx rbx, byte [mouse_packet+0]
	mov al, bl
	and al, 0x1
	mov byte [mouse_l], al
	mov al, bl
	shr al, 1
	and al, 0x1
	mov byte [mouse_r], al
	mov al, bl
	shr al, 2
	and al, 0x1
	mov byte [mouse_m], al

	shl rbx, 4
	and rbx, 0x100
	movzx rax, byte [mouse_packet+1]
	sub rax, rbx
	add qword [mouse_x], rax

	movzx rbx, byte [mouse_packet+0]
	shl rbx, 3
	and rbx, 0x100
	movzx rax, byte [mouse_packet+2]
	sub rax, rbx
	add qword [mouse_y], rax

	movsx rax, byte [mouse_packet+3]
	add qword [mouse_z], rax

	.end:
	mov rax, 0xFEE000B0
	mov dword [rax], 0
	pop rbx
	pop rax
iretq


PS2_mouse_IRQ_3bytes:
	push rax
	push rbx
	inc qword [mos_cnt]

	in al, 0x60
	lea rbx, [mouse_packet]
	add rbx, qword [mouse_byte_recv]
	mov byte [rbx], al
	inc qword [mouse_byte_recv]
	cmp qword [mouse_byte_recv], 3
	jb .end

	mov qword [mouse_byte_recv], 0

	movzx rbx, byte [mouse_packet+0]
	mov al, bl
	and al, 0x1
	mov byte [mouse_l], al
	mov al, bl
	shr al, 1
	and al, 0x1
	mov byte [mouse_r], al
	mov al, bl
	shr al, 2
	and al, 0x1
	mov byte [mouse_m], al

	shl rbx, 4
	and rbx, 0x100
	movzx rax, byte [mouse_packet+1]
	sub rax, rbx
	add qword [mouse_x], rax

	movzx rbx, byte [mouse_packet+0]
	shl rbx, 3
	and rbx, 0x100
	movzx rax, byte [mouse_packet+2]
	sub rax, rbx
	add qword [mouse_y], rax

	.end:
	mov rax, 0xFEE000B0
	mov dword [rax], 0
	pop rbx
	pop rax
iretq