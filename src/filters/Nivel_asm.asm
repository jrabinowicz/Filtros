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
		movdqu xmm2,xmm15
		movdqu xmm0,xmm14
		
		call cuentas 
		
		movdqu [rsi],xmm0		; pegar en dst

		add rdi, 16
		add rsi, 16 
		sub r13, 16
		jmp .ciclo
	.fin:
	pop r13
	pop rbp
	ret


cuentas:
	;xmm0 = mascara
	;xmm1 = data
	;xmm2 = transparencia

	push rbp
	mov rbp,rsp

	pand xmm1,xmm0
	pcmpeqb xmm1,xmm0
	por xmm1, xmm2

	movdqu xmm0,xmm1

	pop rbp 
	ret