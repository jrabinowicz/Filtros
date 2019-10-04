%define size 64
%define size_2 32
%define size_16 4

global Rombos_asm

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
	push r13
	push r14
	push r15
	push rbx

	xor r12, r12 ;r12d = contador filas
	dec r12d

.filas:
	inc r12d
	xor r14, r14 ;r14 = contador columnas
	cmp r12d, ecx
	je .fin

.columnas:
	cmp r14d, edx
	je .filas
	xor r10, r10
	mov r10d, r12d
	shl r10, 26 ;r10 = i%size
	shr r10, 26

	xor r11, r11
	mov r11d, r14d
	shl r11, 26 ;r11 = j%size 
	shr r11, 26

	inc r14d
	xor r13, r13
	mov r13d, r14d
	shl r13, 26 
	shr r13, 26 ;r13 = j+1%size 

	inc r14d
	xor r15, r15
	mov r15d, r14d
	shl r15, 26 ;r15 = j+2%size 
	shr r15, 26

	inc r14d
	xor rbx, rbx
	mov ebx, r14d
	shl ebx, 26 ;rbx = j+3%size 
	shr rbx, 26

	sub r10, size_2;r10 = i%size - 32 
	sub r11, size_2 ;r11 = j%size - 32
	sub r13, size_2 ;r13 = j+1%size - 32
	sub r15, size_2 ;r15 = j+2%size - 32
	sub rbx, size_2 ;rbx = j+3%size - 32

	cmp r10, 0
	jge .seguirJ
	xor r8, r8 
	sub r8, r10
	mov r10, r8

.seguirJ:
	cmp r11, 0
	jge .seguirJ1
	xor r8, r8 
	sub r8, r11
	mov r11, r8

.seguirJ1:
	cmp r13, 0
	jge .seguirJ2
	xor r8, r8 
	sub r8, r13
	mov r13, r8

.seguirJ2:
	cmp r15, 0
	jge .seguirJ3
	xor r8, r8 
	sub r8, r15
	mov r15, r8

.seguirJ3:
	cmp rbx, 0
	jge .seguir
	xor r8, r8 
	sub r8, rbx
	mov rbx, r8	

.seguir:	
	add r11, r10
	add r13, r10
	add r15, r10
	add rbx, r10

	sub r11, size_2
	sub r13, size_2
	sub r15, size_2
	sub rbx, size_2

	cmp r11, size_16
	jg .ceroJ
	shl r11, 1

.compJ1:
	cmp r13, size_16
	jg .ceroJ1
	shl r13, 1

.compJ2:
	cmp r15, size_16
	jg .ceroJ2
	shl r15, 1

.compJ3:
	cmp rbx, size_16
	jg .ceroJ3
	shl rbx, 1
	jmp .buscarPix

.ceroJ:
	xor r11, r11
	jmp .compJ1

.ceroJ1:
	xor r13, r13
	jmp .compJ2

.ceroJ2:
	xor r15, r15
	jmp .compJ3	

.ceroJ3:
	xor rbx, rbx		

.buscarPix:
	;PRIMER PIXEL
	mov r10d, [rdi] ;levanto 1 pixel: r10 = [0,0,0,0,a,r,g,b]
	cmp r11, 0
	jge .sumarJ
	xor r8, r8
	sub r8, r11 ;r8 = [0,0,0,0,0,0,0,x0]
	sub r10, r8
	shl r8, 8 ;r8 = [0,0,0,0,0,0,x0,0]
	sub r10, r8
	shl r8, 8 ;r8 = [0,0,0,0,0,x0,0,0]
	sub r10, r8
	jmp .movPix

.sumarJ:
 	;r11 = [0,0,0,0,0,0,0,x0]
 	add r10, r11
	shl r11, 8 ;r11 = [0,0,0,0,0,0,x0,0]
	add r10, r11
	shl r11, 8 ;r11 = [0,0,0,0,0,x0,0,0]
	add r10, r11
 	
.movPix:	
	;transparencia
	add r10d, 0xFF000000
 	mov [rsi], r10d
 	add rdi, 4
 	add rsi, 4
 	;SEGUNDO PIXEL
 	mov r10d, [rdi] ;levanto 1 pixel: r10 = [0,0,0,0,a,r,g,b]
	cmp r13, 0
	jge .sumarJ1
	xor r8, r8
	sub r8, r13 ;r8 = [0,0,0,0,0,0,0,x1]
	sub r10, r8
	shl r8, 8 ;r8 = [0,0,0,0,0,0,x1,0]
	sub r10, r8
	shl r8, 8 ;r8 = [0,0,0,0,0,x1,0,0]
	sub r10, r8
	jmp .movPix1

.sumarJ1:
 	;r13 = [0,0,0,0,0,0,0,x1]
 	add r10, r13
	shl r13, 8 ;r13 = [0,0,0,0,0,0,x1,0]
	add r10, r13
	shl r13, 8 ;r13 = [0,0,0,0,0,x1,0,0]
	add r10, r13
 	
.movPix1:	
	;transparencia
	add r10d, 0xFF000000
 	mov [rsi], r10d
 	add rdi, 4
 	add rsi, 4
 	;TERCER PIXEL
 	mov r10d, [rdi] ;levanto 1 pixel: r10 = [0,0,0,0,a,r,g,b]
	cmp r15, 0
	jge .sumarJ2
	xor r8, r8
	sub r8, r15 ;r8 = [0,0,0,0,0,0,0,x2]
	sub r10, r8
	shl r8, 8 ;r8 = [0,0,0,0,0,0,x2,0]
	sub r10, r8
	shl r8, 8 ;r8 = [0,0,0,0,0,x2,0,0]
	sub r10, r8
	jmp .movPix2

.sumarJ2:
 	;r15 = [0,0,0,0,0,0,0,x2]
 	add r10, r15
	shl r15, 8 ;r15 = [0,0,0,0,0,0,x2,0]
	add r10, r15
	shl r15, 8 ;r15 = [0,0,0,0,0,x2,0,0]
	add r10, r15
 	
.movPix2:	
	;transparencia
	add r10d, 0xFF000000
 	mov [rsi], r10d
	add rdi, 4
 	add rsi, 4
 	;CUARTO PIXEL
 	mov r10d, [rdi] ;levanto 1 pixel: r10 = [0,0,0,0,a,r,g,b]
	cmp rbx, 0
	jge .sumarJ3
	xor r8, r8
	sub r8, rbx ;r8 = [0,0,0,0,0,0,0,x3]
	sub r10, r8
	shl r8, 8 ;r8 = [0,0,0,0,0,0,x3,0]
	sub r10, r8
	shl r8, 8 ;r8 = [0,0,0,0,0,x3,0,0]
	sub r10, r8
	jmp .movPix3

.sumarJ3:
 	;rbx = [0,0,0,0,0,0,0,x3]
 	add r10, rbx
	shl rbx, 8 ;rbx = [0,0,0,0,0,0,x3,0]
	add r10, rbx
	shl rbx, 8 ;rbx = [0,0,0,0,0,x3,0,0]
	add r10, rbx
 	
.movPix3:	
	;transparencia
	add r10d, 0xFF000000
 	mov [rsi], r10d
	add rdi, 4
	add rsi, 4
	inc r14d
	jmp .columnas

.fin:
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret