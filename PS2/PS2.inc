PS2_DATA equ 0x60
PS2_STATUS equ 0x64
PS2_COMMAND equ 0x64


%macro PS2_send_cmd 1 ; issue a command to PS/2 controller
	%%L_1:
		in al, PS2_STATUS
		test al, 0x2
	jnz %%L_1

	mov al, %1
	out PS2_COMMAND, al
%endmacro

%macro PS2_send_byte 1 ; send a byte to PS/2 controller
	%%L_1:
		in al, PS2_STATUS
		test al, 0x2
	jnz %%L_1

	mov al, %1
	out PS2_DATA, al
%endmacro

%macro PS2_recv_rsp 0 ; recieve a command response from a PS/2 controller
	%%L_1:
		in al, PS2_STATUS
		test al, 0x1
	jz %%L_1

	in al, PS2_DATA
%endmacro




; ah - byte to send
; return value in rax: 0 - success, -1 failure
PS2_port2_sendbyte:
	;mov al, 0xD4
	;out 0x64, al
	PS2_send_cmd 0xD4
PS2_port1_sendbyte:
	mov ecx, 500
	.poll_status:
		pause
		in al, 0x64
		test al, 00000010b
		jz .can_write
		dec ecx
	jnz .poll_status
	mov rax, -1
ret
	.can_write:
	mov al, ah
	out 0x60, al
	xor eax, eax
ret


; return value in rax: al=recvbyte - success, rax=-1 - failure
PS2_port1_recvbyte_poll:
	mov ecx, 500
	xor eax, eax
	.poll_status:
		pause
		in al, 0x64
		test al, 00000001b
		jnz .can_read
		dec ecx
	jnz .poll_status
	mov rax, -1
ret
	.can_read:
	in al, 0x60
ret

; return value in rax: al=recvbyte - success, rax=-1 - failure
PS2_port2_recvbyte_poll:
	;mov al, 0xD4
	;out 0x64, al
	;PS2_send_cmd 0xD4
	mov ecx, 500
	xor eax, eax
	.poll_status:
		pause
		in al, 0x64
		test al, 00100000b
		jnz .can_read
		dec ecx
	jnz .poll_status
	mov rax, -1
ret
	.can_read:
	in al, 0x60
ret



; no explicit args
; implicit - requires FADT global variable
; return value: 1 - present, 0 - not present
check_PS2_prescense:
	mov rax, -1
	cmp qword [FADT], 0
	jz .end
	mov rax, qword [FADT]
	movzx eax, word [rax+109]
	bt eax, 1
	mov eax, 0
	adc eax, 0
.end:
ret

; add later
disable_USB_legacy:


PS2_init:
	call check_PS2_prescense
	test eax, eax
	jz .error_0

	cli

	; call disable_USB_legacy

	; disable attached devices
	PS2_send_cmd 0xAD
	PS2_send_cmd 0xA7 

	; flush output buffer
	in al, 0x60

	; set the controller conf byte
	PS2_send_cmd 0x20
	PS2_recv_rsp
	and al, 10101110b
	mov ah, al
	PS2_send_cmd 0x60
	PS2_send_byte ah

	; perform controller self test
	PS2_send_cmd 0xAA
	PS2_recv_rsp
	cmp al, 0x55
	jne .error_1
	PS2_send_cmd 0x60 ; restore the conf byte if self test reseted 8042
	PS2_send_byte ah

	; determine if there are 2 channels
	PS2_send_cmd 0xA8
	PS2_send_cmd 0x20
	PS2_recv_rsp
	test al, 00100000b
	jz .dual_channel_controller
	mov byte [single_channel_PS2], 1
	jmp .single_channel_controller
	.dual_channel_controller:
	PS2_send_cmd 0xA7
	PS2_send_cmd 0x20
	PS2_recv_rsp
	and al, 11011101b
	mov ah, al
	PS2_send_cmd 0x60
	PS2_send_byte ah
	.single_channel_controller:

	; perform interface tests
	PS2_send_cmd 0xAB
	PS2_recv_rsp
	cmp al, 0
	jne .port_1_bad
	mov byte [PS2_port_1_working], 1
	.port_1_bad:
	cmp byte [single_channel_PS2], 1
	je .port_2_bad
	PS2_send_cmd 0xA9
	PS2_recv_rsp
	cmp al, 0
	jne .port_2_bad
	mov byte [PS2_port_2_working], 1
	.port_2_bad:

	; enable devices
	cmp byte [PS2_port_1_working], 1
	jne .skip_enable_1
	PS2_send_cmd 0xAE
	.skip_enable_1:
	cmp byte [PS2_port_2_working], 1
	jne .skip_enable_2
	PS2_send_cmd 0xA8
	.skip_enable_2:
	; enable ints?????

	; reset devices
	cmp byte [PS2_port_1_working], 1
	jne .skip_port_1_reset
	.reset_1_resend:
	mov ah, 0xFF
	call PS2_port1_sendbyte
	call PS2_port1_recvbyte_poll
	cmp al, 0xFE
	jz .reset_1_resend
	cmp al, 0xFA
	jz .reset_1_nextb_0
	cmp al, 0xAA
	jz .reset_1_nextb_0
	mov byte [PS2_port_1_working], 0
	jmp .skip_port_1_reset
	.reset_1_nextb_0:
	call PS2_port1_recvbyte_poll
	cmp al, 0xFA
	jz .reset_1_good
	cmp al, 0xAA
	jz .reset_1_good
	mov byte [PS2_port_1_working], 0
	jmp .skip_port_1_reset
	.reset_1_good:
	call PS2_keyboard_init

	; identify
	mov ah, 0xF5
	call PS2_port1_sendbyte ; send disable scanning to device
	call PS2_port1_recvbyte_poll
	cmp al, 0xFA
	jz .identify_1_nextb_0
	mov byte [PS2_port_1_working], 0
	jmp .skip_port_1_reset
	.identify_1_nextb_0:
	mov ah, 0xF2 ; send identify command
	call PS2_port1_sendbyte ; send disable scanning to device
	call PS2_port1_recvbyte_poll	
	cmp al, 0xFA
	jz .identify_1_nextb_1
	mov byte [PS2_port_1_working], 0
	jmp .skip_port_1_reset
	.identify_1_nextb_1:
	call PS2_port1_recvbyte_poll
	mov byte [port_1_dev_id], al
	call PS2_port1_recvbyte_poll
	mov byte [port_1_dev_id+1], al
	mov ah, 0xF4 ; send enable scanning to device
	call PS2_port1_sendbyte
	call PS2_port1_recvbyte_poll
	cmp al, 0xFA
	jz .identify_1_good
	mov byte [PS2_port_1_working], 0
	jmp .skip_port_1_reset
	.identify_1_good:

	.skip_port_1_reset:
	; only identify for second dev so far
	cmp byte [PS2_port_2_working], 1
	jne .skip_port_2_reset
	;call PS2_mouse_init ; going to set sample rate to support Z axis
	mov ah, 0xF2
	call PS2_port2_sendbyte
	call PS2_port2_recvbyte_poll
	cmp al, 0xFA
	je .identify_2_nextb_0
	mov byte [PS2_port_2_working], 0
	jmp .skip_port_2_reset
	.identify_2_nextb_0:
	call PS2_port2_recvbyte_poll
	mov byte [port_2_dev_id], al
	call PS2_port2_recvbyte_poll
	mov byte [port_2_dev_id+1], al
	.skip_port_2_reset:

	; route interrupts
	cmp byte [PS2_port_1_working], 1
	jne .skip_route_1

	mov rax, 0x34 ; gonna use 0x34 for now
	mov bx, cs
	xor dl, dl
	mov dh, 0x8E
	lea rcx, [PS2_keyboard_IRQ]
	call write_IDT_gate

	mov rax, 1 ; port1 - IRQ1
	call get_ioapic_id_offs
	mov dword [rax], edx
	mov edx, 0x34
	bts edx, 13
	mov dword [rax+0x10], edx     ; routing the interrupt hopefully)
	inc dword [rax]
	mov rdx, qword [lapic]
	mov edx, dword [rdx+0x20]
	shl edx, 24
	mov dword [rax+0x10], edx
	.skip_route_1:

	cmp byte [PS2_port_2_working], 1
	jne .skip_route_2

	mov rax, 0x35
	mov bx, cs
	xor dl, dl
	mov dh, 0x8E
	cmp byte [port_2_dev_id], 0
	jne .mouse_advanced
	lea rcx, [PS2_mouse_IRQ_3bytes] ; substitute the IRQ if we have 4 byte sized packets w wheel
	.mouse_advanced_end:
	call write_IDT_gate

	mov rax, 12 ; port2 - IRQ2
	call get_ioapic_id_offs
	mov dword [rax], edx
	mov edx, 0x35
	bts edx, 13
	mov dword [rax+0x10], edx
	inc dword [rax]
	mov rdx, qword [lapic]
	mov edx, dword [rdx+0x20]
	shl edx, 24
	mov dword [rax+0x10], edx
	.skip_route_2:

	; enable ints
	cmp byte [PS2_port_1_working], 1
	jne .skip_enable_int_1
	PS2_send_cmd 0x20
	PS2_recv_rsp
	or al, 00000001b
	mov ah, al
	PS2_send_cmd 0x60
	PS2_send_byte ah
	.skip_enable_int_1:

	cmp byte [PS2_port_2_working], 1
	jne .skip_enable_int_2
	mov ah, 0xF4
	call PS2_port2_sendbyte
	call PS2_port2_recvbyte_poll
	PS2_send_cmd 0x20
	PS2_recv_rsp
	or al, 00000010b
	mov ah, al
	PS2_send_cmd 0x60
	PS2_send_byte ah
	.skip_enable_int_2:


	sti
	xor rax, rax
ret

.error_0:
	mov rax, -1 ; controller not present
ret

.error_1:
	mov rax, -2
ret

.mouse_advanced:
	lea rcx, [PS2_mouse_IRQ_3bytes]
jmp .mouse_advanced_end

%include "PS2_keyboard.inc"
%include "PS2_mouse.inc"


