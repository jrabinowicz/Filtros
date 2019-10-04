global Rombos_asm
section .rodata
align 16
size_2: dd 32,32,32,32
size_16: dd 4,4,4,4

maskTransparencia: db 0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF
maskSh: db 0x00,0x00,0x00,0x00,0x04,0x04,0x04,0x04,0x08,0x08,0x08,0x08,0x0c,0x0c,0x0c,0x0c
inicio: dd 0x00,0x01,0x02,0x03
todos1: dd 0x01,0x01,0x01,0x01

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

    movdqa xmm10,[maskTransparencia] ;xmm10 = maskTransparencia
    movdqa xmm11,[size_2] ;xmm11 = size_2
    movdqa xmm12,[size_16] ;xmm12 = size_16
    movdqa xmm15, [maskSh]
    movdqa xmm5,[inicio] 
    movdqa xmm6, [todos1]

	xor r12, r12 ;r12d = contador filas
	dec r12d

	psubd xmm1, xmm6

.filas:

	inc r12d
	xor r14, r14 ;r14 = contador columnas
	paddd xmm1, xmm6 ;sumamos uno al contador de filas
	movdqu xmm9, xmm5 ;volvemos al inicio de las columnas (0,1,2,3)

	movdqu xmm9,xmm5   ;instrucción de más

	cmp r12d, ecx
	je .fin

.columnas:
	cmp r14d, r9d
	je .filas
 	movdqu xmm2, xmm11 ;xmm2 = [32|32|32|32]
 	movdqu xmm14, xmm11 ;xmm14 = [32|32|32|32]

 	movdqu xmm14, xmm11  ;instrucciones de más
  	movdqu xmm14, xmm11
 	movdqu xmm14, xmm11
 	movdqu xmm14, xmm11
 	movdqu xmm14, xmm11
	
	movdqu xmm13, xmm9
	movdqu xmm3, xmm1
	pslld xmm3, 26 ; el resto de dividir por 64 son los ultimos 6 bits
	psrld xmm3, 26
	pslld xmm13, 26 ; el resto de dividir por 64 son los ultimos 6 bits
	psrld xmm13, 26

; ----------- xmm3 = [i%size x4]
;			  xmm13 = [para j hasta j+3 %size x4]

	psubd xmm2, xmm3 ;xmm2 = (size/2)-(i%size) para cada i, y cada resultado ocupa un byte
					 ;xmm2 = [00|00|00|(size/2)-(i%size)|00...]

	psubd xmm14, xmm13 ;xmm14 = (size/2)-(j%size) para cada j+3...j, y cada resultado ocupa un byte

	pabsd xmm2, xmm2
	pabsd xmm14, xmm14

	paddd xmm2, xmm14 ;xmm2 = [ii+(j+3)(j+3)...ii+jj]

	movdqu xmm3, xmm11 ;xmm3 = [32,32,32,32]
	psubd xmm2, xmm3 ;xmm2 = [ii+(j+3)(j+3)-32|...|ii+jj -32]

	movdqu xmm3, xmm12 ;xmm3 = [4,4,4,4]
	movdqu xmm4, xmm2 
	pcmpgtd xmm4, xmm3 ;en xmm4 hay 1 si es mayor a xmm3 y 0 si no 

	movdqu xmm3, xmm2
	pslld xmm3, 1 ;multiplicamos por 2

	pandn xmm4, xmm3 ;xmm4 = [x3|x2|x1|x0], donde x ocupa 1 byte

	movdqu xmm7, xmm4
	pcmpgtd xmm7, xmm0 ;xmm7 tiene 1 si es >0 y 0 si no, esto deberia ser byte
	movdqu xmm8, xmm4 
	pand xmm8, xmm7 ;xmm8 ponemos los positivos
	pandn xmm7, xmm4 ;xmm7 tiene los negativos

	pabsd xmm7, xmm7

	pshufb xmm7, xmm15
	pshufb xmm8, xmm15

	movdqu xmm4, [rdi]  ;levanto 4 pixeles
	psubusb xmm4, xmm7 ;SAT(src[i][j].b + x) para cada byte de cada pixel
	paddusb xmm4, xmm8

	por xmm4, xmm10 ;transparencia en ff

	movdqu [rsi], xmm4

	paddd xmm9, xmm12
	add rdi, 16