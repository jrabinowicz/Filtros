;experimento llamado a funciones: 3 llamados a cada funcion

%define size_componente 1
%define size_pixel 4

global Nivel_asm
section .rodata
align 16
mask0: times 16 db 0x01
mask1: times 16 db 0x02
mask2: times 16 db 0x04
mask3: times 16 db 0x08
mask4: times 16 db 0x10
mask5: times 16 db 0x20
mask6: times 16 db 0x40
mask7: times 16 db 0x80


maskTransp: db 0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF

section .text
Nivel_asm:

	;rdi = *src
	;rsi = *dst
	;edx = width
	;ecx = height
	;r8d = src_row_size
	;r9d = dst_row_size
	;rsp -> indice
	push rbp
	mov rbp, rsp
	mov r10d, [rbp + 16]		;r10 = indice
	push r13

	xor rax, rax
	mov ecx, ecx
	mov eax, r8d
	mul rcx 
	mov r13, rax 				; r13 = row_size * columnas (en bytes)

	mov eax, 16
	mul r10d
	mov eax, eax
	movdqa xmm14, [mask0 + rax] 	; xmm0 = mascara 
	movdqa xmm15, [maskTransp]

	.ciclo:
		cmp r13, 0
		je .fin
		movdqu xmm1, [rdi] 		; levantamos 4 pixeles
		movdqu xmm2, xmm1  

		movdqu xmm0,xmm14
		;xmm0 = mascara
		;xmm1 = data
		call hacerAnd1 			

		movdqu xmm1,xmm14
		;xmm0 = resultado del and
		;xmm1 = mascara
		call hacerComparacion1

		movdqu xmm1,xmm15
		;xmm0 = resultado de comparacion
		;xm1 = mascaraTransparencia 
		call transparencia1 
		;xmm0 = resultado final
		
		movdqu [rsi],xmm0		; pegar en dst

		add rdi, 16
		add rsi, 16 
		sub r13, 16
		jmp .ciclo
	.fin:
	pop r13
	pop rbp
	ret


hacerAnd1:
	;xmm0 = primer operando
	;xmm1 = segundo operando

	push rbp
	mov rbp,rsp

	call hacerAnd2

	pop rbp 
	ret

hacerAnd2:
	;xmm0 = primer operando
	;xmm1 = segundo operando

	push rbp
	mov rbp,rsp

	call hacerAnd3

	pop rbp 
	ret


hacerAnd3:
	;xmm0 = primer operando
	;xmm1 = segundo operando

	push rbp
	mov rbp,rsp

	pand xmm0,xmm1   ;xmm0 = resultado que devuelvo

	pop rbp 
	ret




hacerComparacion1:
	;xmm0 = primer operando
	;xmm1 = segundo operando

	push rbp
	mov rbp,rsp

	call hacerComparacion2

	pop rbp 
	ret


hacerComparacion2:
	;xmm0 = primer operando
	;xmm1 = segundo operando

	push rbp
	mov rbp,rsp

	call hacerComparacion3

	pop rbp 
	ret


hacerComparacion3:
	;xmm0 = primer operando
	;xmm1 = segundo operando

	push rbp
	mov rbp,rsp

	pcmpeqb xmm0,xmm1

	pop rbp 
	ret


transparencia1:
	;xmm0 = primer operando
	;xmm1 = segundo operando

	push rbp
	mov rbp,rsp 

	call transparencia2

	pop rbp 
	ret

transparencia2:
	;xmm0 = primer operando
	;xmm1 = segundo operando

	push rbp
	mov rbp,rsp 

	call transparencia3

	pop rbp 
	ret

transparencia3:
	;xmm0 = primer operando
	;xmm1 = segundo operando

	push rbp
	mov rbp,rsp 

	por xmm0,xmm1

	pop rbp 
	ret