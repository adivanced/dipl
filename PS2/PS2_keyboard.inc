PS2_keyboard_init: ; get scan code set, if ~2 => set 2
	mov ah, 0xF0
	call PS2_port1_sendbyte
	call PS2_port1_recvbyte_poll
	mov ah, 0x00
	call PS2_port1_sendbyte	
	call PS2_port1_recvbyte_poll
	call PS2_port1_recvbyte_poll
	cmp al, 0x02
	je .end

	mov ah, 0xF0
	call PS2_port1_sendbyte
	call PS2_port1_recvbyte_poll
	mov ah, 0x02
	call PS2_port1_sendbyte	
	call PS2_port1_recvbyte_poll
	call PS2_port1_recvbyte_poll

	.end:
ret



PS2_keyboard_IRQ:
	inc qword [kbd_cnt]
	push rax
	push rbx
	in al, 0x60 ; get scan code

	cmp al, 0xE0
	je .got_E0

	cmp al, 0xF0
	je .got_F0

	cmp byte [sccode_got_E0], 1
	je .E0_set

	cmp byte [sccode_got_F0], 1
	je .E0_nset_F0_set

	.E0_nset_F0_nset:
		movzx rax, al
		lea rbx, [sccode_lookup_0]
		mov al, byte [rbx+rax]
		mov byte [sccode_got_E0], 0
		mov byte [sccode_got_F0], 0


	.store_code:
	lea rbx, [sccode_circ_buf]
	add rbx, qword [sccode_circ_buf_ptr]
	mov byte [rbx], al
	inc qword [sccode_circ_buf_ptr]
	cmp qword [sccode_circ_buf_ptr], 512
	jne .skip_ptr_reset
	mov qword [sccode_circ_buf_ptr], 0
	.skip_ptr_reset:
	; set pressed flag

	.end:
	mov rax, 0xFEE000B0
	mov dword [rax], 0
	pop rbx
	pop rax
iretq

.E0_set:
	cmp byte [sccode_got_F0], 1
	je .E0_set_F0_set
	.E0_set_F0_nset:
		movzx rax, al
		lea rbx, [sccode_lookup_1]
		mov al, byte [rbx+rax]
		mov byte [sccode_got_E0], 0
		mov byte [sccode_got_F0], 0		
jmp .store_code
	.E0_set_F0_set:
		movzx rax, al
		lea rbx, [sccode_lookup_3]
		mov al, byte [rbx+rax]
		mov byte [sccode_got_E0], 0
		mov byte [sccode_got_F0], 0		
jmp .store_code
	.E0_nset_F0_set:
		movzx rax, al
		lea rbx, [sccode_lookup_2]
		mov al, byte [rbx+rax]
		mov byte [sccode_got_E0], 0
		mov byte [sccode_got_F0], 0
jmp .store_code


.got_E0:
	mov byte [sccode_got_E0], 1
jmp .end

.got_F0:
	mov byte [sccode_got_F0], 1
jmp .end
