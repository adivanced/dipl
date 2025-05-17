	.file	"code.c"
	.intel_syntax noprefix
; GNU C17 (Ubuntu 11.4.0-1ubuntu1~22.04) version 11.4.0 (x86_64-linux-gnu)
;	compiled by GNU C version 11.4.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

; GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
; options passed: -masm=intel -mno-red-zone -mtune=generic -march=x86-64 -O3 -fcf-protection=none -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm -ffreestanding -fshort-wchar -fstack-clash-protection
	.text
	.p2align 4
	.globl	test
	.type	test, @function
test:
; code.c:8: 	for(uint64_t i = 0; i < n; i++){
	test	rsi, rsi	; n
	je	.L29	;,
; code.c:7: void test(uint64_t* arr, uint64_t n){
	push	rbx	;
	mov	r10, rsi	; n, tmp130
	mov	r8, rdi	; ivtmp.21, arr
; code.c:8: 	for(uint64_t i = 0; i < n; i++){
	xor	r9d, r9d	; ivtmp.19
; code.c:9: 		arr[i] = arr[i] * arr[i]/100;
	movabs	rbx, 2951479051793528259	; tmp111,
; code.c:8: 	for(uint64_t i = 0; i < n; i++){
	xor	r11d, r11d	; i
	.p2align 4,,10
	.p2align 3
.L16:
; code.c:9: 		arr[i] = arr[i] * arr[i]/100;
	mov	rdx, QWORD PTR [r8]	; _3, MEM[(uint64_t *)_86]
; code.c:10: 		if(i+1 < n){
	add	r11, 1	; i,
; code.c:9: 		arr[i] = arr[i] * arr[i]/100;
	imul	rdx, rdx	; tmp108, _3
; code.c:9: 		arr[i] = arr[i] * arr[i]/100;
	shr	rdx, 2	; tmp109,
	mov	rax, rdx	; tmp109, tmp109
	mul	rbx	; tmp111
	shr	rdx, 2	; _5,
; code.c:9: 		arr[i] = arr[i] * arr[i]/100;
	mov	QWORD PTR [r8], rdx	; MEM[(uint64_t *)_86], _5
; code.c:10: 		if(i+1 < n){
	cmp	r11, r10	; i, n
	jnb	.L3	;,
; code.c:11: 			arr[i] *= arr[i+1]+1;
	mov	rax, QWORD PTR 8[r8]	; tmp134, MEM[(uint64_t *)_86 + 8B]
; code.c:14: 			if(arr[i-1] != 0){
	mov	rcx, QWORD PTR -8[r8]	; _75, MEM[(uint64_t *)_86 + -8B]
; code.c:11: 			arr[i] *= arr[i+1]+1;
	add	rax, 1	; tmp112,
; code.c:11: 			arr[i] *= arr[i+1]+1;
	imul	rax, rdx	; _11, _5
	mov	QWORD PTR [r8], rax	; MEM[(uint64_t *)_86], _11
; code.c:14: 			if(arr[i-1] != 0){
	test	rcx, rcx	; _75
	je	.L20	;,
; code.c:15: 				arr[i] /= arr[i-1];
	xor	edx, edx	; tmp126
	div	rcx	; _75
	mov	QWORD PTR [r8], rax	; MEM[(uint64_t *)_86], tmp125
.L20:
; code.c:8: 	for(uint64_t i = 0; i < n; i++){
	mov	rax, r11	; j, i
	jmp	.L8	;
	.p2align 4,,10
	.p2align 3
.L34:
; code.c:20: 				arr[i] *= arr[j];
	imul	rdx, QWORD PTR [r8]	; tmp114, MEM[(uint64_t *)_86]
; code.c:18: 		for(uint64_t j = i+1; j < n; j++){
	add	rax, 1	; j,
; code.c:20: 				arr[i] *= arr[j];
	mov	QWORD PTR [r8], rdx	; MEM[(uint64_t *)_86], tmp114
; code.c:18: 		for(uint64_t j = i+1; j < n; j++){
	cmp	r10, rax	; n, j
	jbe	.L33	;,
.L8:
; code.c:19: 			if(arr[j]){
	mov	rdx, QWORD PTR [rdi+rax*8]	; _19, MEM[(uint64_t *)arr_42(D) + j_69 * 8]
; code.c:19: 			if(arr[j]){
	test	rdx, rdx	; _19
	jne	.L34	;,
; code.c:22: 				if(j%2){
	mov	rdx, rax	; tmp116, j
	and	edx, 1	; tmp116,
; code.c:23: 					arr[j] += 2929;
	cmp	rdx, 1	; tmp116,
	sbb	rdx, rdx	; tmp127
	and	rdx, -9196739	; tmp127,
	add	rdx, 2929	; tmp127,
	mov	QWORD PTR [rdi+rax*8], rdx	; MEM[(uint64_t *)arr_42(D) + j_69 * 8], tmp127
; code.c:18: 		for(uint64_t j = i+1; j < n; j++){
	add	rax, 1	; j,
; code.c:18: 		for(uint64_t j = i+1; j < n; j++){
	cmp	r10, rax	; n, j
	ja	.L8	;,
.L33:
; code.c:29: 		for(uint64_t j = 0; j < i; j++){
	test	r9, r9	; ivtmp.19
	je	.L10	;,
.L17:
; code.c:29: 		for(uint64_t j = 0; j < i; j++){
	xor	ecx, ecx	; j
	jmp	.L14	;
	.p2align 4,,10
	.p2align 3
.L36:
; code.c:31: 				arr[i] /= arr[j];
	mov	rax, QWORD PTR [r8]	; MEM[(uint64_t *)_86], MEM[(uint64_t *)_86]
	xor	edx, edx	; tmp119
; code.c:29: 		for(uint64_t j = 0; j < i; j++){
	add	rcx, 1	; j,
; code.c:31: 				arr[i] /= arr[j];
	div	rsi	; _25
	mov	QWORD PTR [r8], rax	; MEM[(uint64_t *)_86], tmp118
; code.c:29: 		for(uint64_t j = 0; j < i; j++){
	cmp	rcx, r9	; j, ivtmp.19
	jnb	.L35	;,
.L14:
; code.c:30: 			if(arr[j]){
	mov	rsi, QWORD PTR [rdi+rcx*8]	; _25, MEM[(uint64_t *)arr_42(D) + j_68 * 8]
; code.c:30: 			if(arr[j]){
	test	rsi, rsi	; _25
	jne	.L36	;,
; code.c:33: 				if(j%2){
	mov	rax, rcx	; tmp121, j
	and	eax, 1	; tmp121,
; code.c:34: 					arr[j] += 203203;
	cmp	rax, 1	; tmp121,
	sbb	rax, rax	; tmp128
	and	rax, -200134486	; tmp128,
	add	rax, 203203	; tmp128,
	mov	QWORD PTR [rdi+rcx*8], rax	; MEM[(uint64_t *)arr_42(D) + j_68 * 8], tmp128
; code.c:29: 		for(uint64_t j = 0; j < i; j++){
	add	rcx, 1	; j,
; code.c:29: 		for(uint64_t j = 0; j < i; j++){
	cmp	rcx, r9	; j, ivtmp.19
	jb	.L14	;,
.L35:
; code.c:8: 	for(uint64_t i = 0; i < n; i++){
	cmp	r11, r10	; i, n
	jnb	.L1	;,
.L10:
	add	r9, 1	; ivtmp.19,
	add	r8, 8	; ivtmp.21,
	jmp	.L16	;
	.p2align 4,,10
	.p2align 3
.L3:
; code.c:14: 			if(arr[i-1] != 0){
	mov	rcx, QWORD PTR -8[r8]	; _36, MEM[(uint64_t *)_86 + -8B]
; code.c:14: 			if(arr[i-1] != 0){
	test	rcx, rcx	; _36
	je	.L19	;,
; code.c:15: 				arr[i] /= arr[i-1];
	mov	rax, rdx	; _5, _5
	xor	edx, edx	; tmp124
	div	rcx	; _36
	mov	QWORD PTR [r8], rax	; MEM[(uint64_t *)_86], tmp123
	.p2align 4,,10
	.p2align 3
.L19:
; code.c:29: 		for(uint64_t j = 0; j < i; j++){
	test	r9, r9	; ivtmp.19
	jne	.L17	;,
.L1:
; code.c:41: }
	pop	rbx	;
	ret	
.L29:
	ret	
	.size	test, .-test
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
