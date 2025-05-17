	.file	"dipl.c"
	.intel_syntax noprefix
; GNU C17 (Ubuntu 11.4.0-1ubuntu1~22.04) version 11.4.0 (x86_64-linux-gnu)
;	compiled by GNU C version 11.4.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

; GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
; options passed: -masm=intel -mtune=generic -march=x86-64 -fcf-protection=none -fno-asynchronous-unwind-tables -fno-dwarf2-cfi-asm -fstack-protector-strong -fstack-clash-protection
	.text
	.globl	test
	.type	test, @function
test:
	push	rbp	;
	mov	rbp, rsp	;,
	mov	QWORD PTR -24[rbp], rdi	; arr, arr
	mov	QWORD PTR -32[rbp], rsi	; n, n
; code.c:5: 	for(uint64_t i = 0; i < n; i++){
	mov	QWORD PTR -16[rbp], 0	; i,
; code.c:5: 	for(uint64_t i = 0; i < n; i++){
	jmp	.L2	;
.L6:
; code.c:6: 		arr[i] = arr[i] * arr[i]/100;
	mov	rax, QWORD PTR -16[rbp]	; tmp123, i
	lea	rdx, 0[0+rax*8]	; _1,
	mov	rax, QWORD PTR -24[rbp]	; tmp124, arr
	add	rax, rdx	; _2, _1
	mov	rdx, QWORD PTR [rax]	; _3, *_2
; code.c:6: 		arr[i] = arr[i] * arr[i]/100;
	mov	rax, QWORD PTR -16[rbp]	; tmp125, i
	lea	rcx, 0[0+rax*8]	; _4,
	mov	rax, QWORD PTR -24[rbp]	; tmp126, arr
	add	rax, rcx	; _5, _4
	mov	rax, QWORD PTR [rax]	; _6, *_5
; code.c:6: 		arr[i] = arr[i] * arr[i]/100;
	imul	rax, rdx	; _7, _3
; code.c:6: 		arr[i] = arr[i] * arr[i]/100;
	mov	rdx, QWORD PTR -16[rbp]	; tmp127, i
	lea	rcx, 0[0+rdx*8]	; _8,
	mov	rdx, QWORD PTR -24[rbp]	; tmp128, arr
	add	rcx, rdx	; _9, tmp128
; code.c:6: 		arr[i] = arr[i] * arr[i]/100;
	shr	rax, 2	; tmp129,
	movabs	rdx, 2951479051793528259	; tmp131,
	mul	rdx	; tmp131
	mov	rax, rdx	; tmp130, tmp130
	shr	rax, 2	; tmp130,
; code.c:6: 		arr[i] = arr[i] * arr[i]/100;
	mov	QWORD PTR [rcx], rax	; *_9, _10
; code.c:7: 		if(i+1 < n){
	mov	rax, QWORD PTR -16[rbp]	; tmp132, i
	add	rax, 1	; _11,
; code.c:7: 		if(i+1 < n){
	cmp	QWORD PTR -32[rbp], rax	; n, _11
	jbe	.L3	;,
; code.c:8: 			arr[i] *= arr[i+1];
	mov	rax, QWORD PTR -16[rbp]	; tmp133, i
	lea	rdx, 0[0+rax*8]	; _12,
	mov	rax, QWORD PTR -24[rbp]	; tmp134, arr
	add	rax, rdx	; _13, _12
	mov	rcx, QWORD PTR [rax]	; _14, *_13
; code.c:8: 			arr[i] *= arr[i+1];
	mov	rax, QWORD PTR -16[rbp]	; tmp135, i
	add	rax, 1	; _15,
	lea	rdx, 0[0+rax*8]	; _16,
	mov	rax, QWORD PTR -24[rbp]	; tmp136, arr
	add	rax, rdx	; _17, _16
	mov	rax, QWORD PTR [rax]	; _18, *_17
; code.c:8: 			arr[i] *= arr[i+1];
	mov	rdx, QWORD PTR -16[rbp]	; tmp137, i
	lea	rsi, 0[0+rdx*8]	; _19,
	mov	rdx, QWORD PTR -24[rbp]	; tmp138, arr
	add	rdx, rsi	; _20, _19
	imul	rax, rcx	; _21, _14
	mov	QWORD PTR [rdx], rax	; *_20, _21
.L3:
; code.c:11: 			arr[i] /= arr[i-1]+1;
	mov	rax, QWORD PTR -16[rbp]	; tmp139, i
	lea	rdx, 0[0+rax*8]	; _22,
	mov	rax, QWORD PTR -24[rbp]	; tmp140, arr
	add	rax, rdx	; _23, _22
	mov	rax, QWORD PTR [rax]	; _24, *_23
; code.c:11: 			arr[i] /= arr[i-1]+1;
	mov	rdx, QWORD PTR -16[rbp]	; tmp141, i
	sal	rdx, 3	; _25,
	lea	rcx, -8[rdx]	; _26,
	mov	rdx, QWORD PTR -24[rbp]	; tmp142, arr
	add	rdx, rcx	; _27, _26
	mov	rdx, QWORD PTR [rdx]	; _28, *_27
; code.c:11: 			arr[i] /= arr[i-1]+1;
	lea	rsi, 1[rdx]	; _29,
; code.c:11: 			arr[i] /= arr[i-1]+1;
	mov	rdx, QWORD PTR -16[rbp]	; tmp143, i
	lea	rcx, 0[0+rdx*8]	; _30,
	mov	rdx, QWORD PTR -24[rbp]	; tmp144, arr
	add	rcx, rdx	; _31, tmp144
	mov	edx, 0	; tmp146,
	div	rsi	; _29
	mov	QWORD PTR [rcx], rax	; *_31, _32
; code.c:13: 		for(uint64_t j = i+1; j < n; j++){
	mov	rax, QWORD PTR -16[rbp]	; tmp150, i
	add	rax, 1	; tmp149,
	mov	QWORD PTR -8[rbp], rax	; j, tmp149
; code.c:13: 		for(uint64_t j = i+1; j < n; j++){
	jmp	.L4	;
.L5:
; code.c:14: 			arr[i] += arr[j];
	mov	rax, QWORD PTR -16[rbp]	; tmp151, i
	lea	rdx, 0[0+rax*8]	; _33,
	mov	rax, QWORD PTR -24[rbp]	; tmp152, arr
	add	rax, rdx	; _34, _33
	mov	rcx, QWORD PTR [rax]	; _35, *_34
; code.c:14: 			arr[i] += arr[j];
	mov	rax, QWORD PTR -8[rbp]	; tmp153, j
	lea	rdx, 0[0+rax*8]	; _36,
	mov	rax, QWORD PTR -24[rbp]	; tmp154, arr
	add	rax, rdx	; _37, _36
	mov	rdx, QWORD PTR [rax]	; _38, *_37
; code.c:14: 			arr[i] += arr[j];
	mov	rax, QWORD PTR -16[rbp]	; tmp155, i
	lea	rsi, 0[0+rax*8]	; _39,
	mov	rax, QWORD PTR -24[rbp]	; tmp156, arr
	add	rax, rsi	; _40, _39
	add	rdx, rcx	; _41, _35
	mov	QWORD PTR [rax], rdx	; *_40, _41
; code.c:13: 		for(uint64_t j = i+1; j < n; j++){
	add	QWORD PTR -8[rbp], 1	; j,
.L4:
; code.c:13: 		for(uint64_t j = i+1; j < n; j++){
	mov	rax, QWORD PTR -8[rbp]	; tmp157, j
	cmp	rax, QWORD PTR -32[rbp]	; tmp157, n
	jb	.L5	;,
; code.c:5: 	for(uint64_t i = 0; i < n; i++){
	add	QWORD PTR -16[rbp], 1	; i,
.L2:
; code.c:5: 	for(uint64_t i = 0; i < n; i++){
	mov	rax, QWORD PTR -16[rbp]	; tmp158, i
	cmp	rax, QWORD PTR -32[rbp]	; tmp158, n
	jb	.L6	;,
; code.c:17: }
	nop	
	nop	
	pop	rbp	;
	ret	
	.size	test, .-test
	.section	.rodata
.LC0:
	.string	"%ld\n"
	.text
	.globl	main
	.type	main, @function
main:
	push	rbp	;
	mov	rbp, rsp	;,
	sub	rsp, 48	;,
; dipl.c:7: int main(void){
	mov	rax, QWORD PTR fs:40	; tmp88, MEM[(<address-space-1> long unsigned int *)40B]
	mov	QWORD PTR -8[rbp], rax	; D.2915, tmp88
	xor	eax, eax	; tmp88
; dipl.c:9: 	uint64_t arr[5] = {4, 5, 16, 9, 11};
	mov	QWORD PTR -48[rbp], 4	; arr[0],
	mov	QWORD PTR -40[rbp], 5	; arr[1],
	mov	QWORD PTR -32[rbp], 16	; arr[2],
	mov	QWORD PTR -24[rbp], 9	; arr[3],
	mov	QWORD PTR -16[rbp], 11	; arr[4],
; dipl.c:10: 	test(arr, 5);
	lea	rax, -48[rbp]	; tmp85,
	mov	esi, 5	;,
	mov	rdi, rax	;, tmp85
	call	test	;
; dipl.c:12: 	printf("%ld\n", arr[2]);
	mov	rax, QWORD PTR -32[rbp]	; _1, arr[2]
	mov	rsi, rax	;, _1
	lea	rax, .LC0[rip]	; tmp86,
	mov	rdi, rax	;, tmp86
	mov	eax, 0	;,
	call	printf@PLT	;
	mov	eax, 0	; _11,
; dipl.c:13: }
	mov	rdx, QWORD PTR -8[rbp]	; tmp89, D.2915
	sub	rdx, QWORD PTR fs:40	; tmp89, MEM[(<address-space-1> long unsigned int *)40B]
	je	.L9	;,
	call	__stack_chk_fail@PLT	;
.L9:
	leave	
	ret	
	.size	main, .-main
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
