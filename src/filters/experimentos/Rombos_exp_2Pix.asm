global Rombos_asm
section .rodata
align 16
size_2: dd 32,32,32,32
size_16: dd 4,4,4,4
incCol: dd 2,0,2,0
incFila: dd 0,1,0,1

maskTransparencia: db 0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
maskSh: db 0x00,0x00,0x00,0x00,0x04,0x04,0x04,0x04,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
inicioCol: dd 0,-1,0,-1
inc1: dd 0,0,1,0

section .text

Rombos_asm:

	;rdi = *src
	;rsi = *dst
	;edx = width
	;ecx = height
	;r8d = src_row_size
	;r9d = dst_row_size

	;stackframe
	push rbp
	mov rbp, rsp
	push r12
	push r14

    mov r9d, edx ;r9d = columnas
    pxor xmm1, xmm1
    pxor xmm0, xmm0

    movdqa xmm10, [maskTransparencia] ;xmm10 = maskTransparencia
    movdqa xmm11, [size_2] ;xmm11 = size_2
    movdqa xmm12, [size_16] ;xmm12 = size_16
    movdqa xmm15, [maskSh]
    movdqa xmm5, [incCol] ;xmm5 = inc col 
    movdqa xmm6, [incFila] ;xmm6 = inc fila
    movdqa xmm9, [inicioCol] ;xmm9 = mascara para reiniciar las columnas 
    movdqa xmm13, [inc1]

	xor r12, r12 ;r12d = contador filas
	dec r12d

	psubd xmm1, xmm6

.filas:
	inc r12d
	xor r14, r14 ;r14 = contador columnas
	;xmm1: [i|j+1|i|j]
	paddd xmm1, xmm6 ;sumamos uno al contador de filas
	pand xmm1, xmm9 ;volvemos al inicio de las columnas (i,0,i,0)
	paddd xmm1, xmm13 ;sumo uno a la segunda col
	cmp r12d, ecx
	je .fin

.columnas:
	cmp r14d, r9d
	je .filas
 	movdqu xmm2, xmm11 ;xmm2 = [32|32|32|32]
 	
	movdqu xmm3, xmm1
	pslld xmm3, 26 ;el resto de dividir por 64 son los ultimos 6 bits
	psrld xmm3, 26

	psubd xmm2, xmm3 ;xmm2 = (size/2)-(i%size) para cada i y j, y cada resultado ocupa un byte
					 ;xmm2 = [00|00|00|(size/2)-(i%size)|00...]

	pabsd xmm2, xmm2
	
	;suma horizontal
	phaddd xmm2, xmm2 ;xmm2 = [ii+(j+1)(j+1)|ii+jj|ii+(j+1)(j+1)|ii+jj]

	movdqu xmm3, xmm11 ;xmm3 = [32,32,32,32]
	psubd xmm2, xmm3 ;xmm2 = [ii+(j+1)(j+1)-32|...|ii+jj -32]

	movdqu xmm3, xmm12 ;xmm3 = [4,4,4,4]
	movdqu xmm4, xmm2 
	pcmpgtd xmm4, xmm3 ;en xmm4 hay 1 si es mayor a xmm3 y 0 si no 

	movdqu xmm3, xmm2
	pslld xmm3, 1 ;multiplicamos por 2

	pandn xmm4, xmm3 ;xmm4 = [x1|x0|x1|x0], donde x ocupa 1 byte

	movdqu xmm7, xmm4
	pcmpgtd xmm7, xmm0 ;xmm7 tiene 1 si es >0 y 0 si no
	movdqu xmm8, xmm4 
	pand xmm8, xmm7 ;xmm8 ponemos los positivos
	pandn xmm7, xmm4 ;xmm7 tiene los negativos

	pabsd xmm7, xmm7

	pshufb xmm7, xmm15
	pshufb xmm8, xmm15

	movq xmm4, [rdi] ;levanto 2 pixeles
	psubusb xmm4, xmm7 ;SAT(src[i][j].b + x) para cada byte de cada pixel
	paddusb xmm4, xmm8

	por xmm4, xmm10 ;transparencia en ff

	movdqu [rsi], xmm4

	paddd xmm1, xmm5
	add rdi, 8
	add rsi, 8
	add r14d, 2
	jmp .columnas

.fin:
	pop r14
	pop r12
	pop rbp
	ret