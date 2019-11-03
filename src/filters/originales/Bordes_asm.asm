global Bordes_asm

section .rodata
align 16
blanco: db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF

section .text
Bordes_asm:
    ;rdi = *src
    ;rsi = *dst
    ;edx = width
    ;ecx = height
    ;r8d = src_row_size
    ;r9d = dst_row_size

    ;stackframe
    push rbp
    mov rbp,rsp
    push r12
    push r13
    push r14
    push r15

    ; limpio parte alta de parámetros
    mov edx, edx ; rdx = columnas
    mov ecx, ecx ; rcx = filas

    mov r13,rsi

    ; calculo el final de la matriz
    mov rax, rcx ; rax = filas
    mov r9, rdx ; salvo rdx
    mul rdx ; rax = filas*cols
    mov rdx, r9 ; restauro rdx despues del mul
    sub rax, rdx; rax = filas*cols - col
    lea r9, [rdi + rax - 1] ; r9 = apunta a la posición [N-2, M-2] de matriz
    sub r9, 8
    lea r12, [rsi + rax - 1] ; r12 = apunta a la posición [N-2, M-2] de matriz destino
    sub r12, 8


    ; empiezo desde la posición [1,1] de la imagen
    lea rdi, [rdi + rdx + 1]
    lea rsi, [rsi + rdx + 1]

    ; calculo los punteros a las filas
    mov r10, rdi
    mov r11, rdi
    sub r10, rdx
    add r11, rdx
    ; r10 = puntero a la fila anterior
    ; rdi = puntero a la fila actual
    ; r11 = puntero a la fila siguiente
    
    ; xmm0 va a ser un registro de ceros

    pxor xmm0, xmm0

    ; recorro la imagen
    .ciclo:

        ; traigo todos los pixeles necesarios
        ;   ↖ ↑ ↗  =  xmm1 xmm2 xmm3
        ;   ← ⋅ →  =  xmm4 xmm5 xmm6
        ;   ↙ ↓ ↘  =  xmm7 xmm8 xmm9


        ;movq = limpia parte alta del reg y mueve a la parte baja

        movq xmm1, [r10 - 1]  ; ↖
        movq xmm2, [r10]      ; ↑
        movq xmm3, [r10 + 1]  ; ↗

        movq xmm4, [rdi - 1]  ; ←
        ;movq xmm5, [rdi]      ; ⋅   
        movq xmm6, [rdi + 1]  ; →

        movq xmm7, [r11 - 1]  ; ↙
        movq xmm8, [r11]      ; ↓
        movq xmm9, [r11 + 1]  ; ↘

        ;desempaquetamos (solo hay cosas en las partes bajas)
        punpcklbw xmm1,xmm0
        punpcklbw xmm2,xmm0
        punpcklbw xmm3,xmm0
        punpcklbw xmm4,xmm0        
        punpcklbw xmm6,xmm0
        punpcklbw xmm7,xmm0
        punpcklbw xmm8,xmm0
        punpcklbw xmm9,xmm0
        
        ;salvamos las esquinas para la cuenta Gy
        movdqu xmm10,xmm1
        movdqu xmm11,xmm3
        movdqu xmm12,xmm7
        movdqu xmm13,xmm9

        ;cuenta Gx:
        movdqu xmm14,xmm0 ;acumulador Gx

        psllw xmm4,1
        psllw xmm6,1

        paddw xmm14,xmm9
        paddw xmm14,xmm6
        paddw xmm14,xmm3
        psubw xmm14,xmm1
        psubw xmm14,xmm4
        psubw xmm14,xmm7

        pabsw xmm14,xmm14

        ;cuenta Gy:
        movdqu xmm15,xmm0 ;acumulador Gy

        psllw xmm2,1
        psllw xmm8,1

        paddw xmm15,xmm12
        paddw xmm15,xmm8
        paddw xmm15,xmm13
        psubw xmm15,xmm10
        psubw xmm15,xmm2
        psubw xmm15,xmm11

        pabsw xmm15,xmm15

        ;suma saturada
        paddusw xmm14,xmm15 ;se guarda en xmm14
        packuswb xmm14,xmm0

        movq [rsi],xmm14

        add rdi,8
        add rsi,8
        add r10,8
        add r11,8

        cmp rdi,r9
        jge .ultimaIt
        jmp .ciclo

    .ultimaIt:

        mov rsi, r12

        mov rdi, r9


        ; calculo los punteros a las filas
        mov r10, rdi
        mov r11, rdi
        sub r10, rdx
        add r11, rdx
        ; r10 = puntero a la fila anterior
        ; rdi = puntero a la fila actual
        ; r11 = puntero a la fila siguiente

        movq xmm1, [r10 - 1]  ; ↖
        movq xmm2, [r10]      ; ↑
        movq xmm3, [r10 + 1]  ; ↗

        movq xmm4, [rdi - 1]  ; ←
        ;movq xmm5, [rdi]      ; ⋅  
        movq xmm6, [rdi + 1]  ; →

        movq xmm7, [r11 - 1]  ; ↙
        movq xmm8, [r11]      ; ↓
        movq xmm9, [r11 + 1]  ; ↘

        ;desempaquetamos (solo hay cosas en las partes bajas)
        punpcklbw xmm1,xmm0
        punpcklbw xmm2,xmm0
        punpcklbw xmm3,xmm0
        punpcklbw xmm4,xmm0        
        punpcklbw xmm6,xmm0
        punpcklbw xmm7,xmm0
        punpcklbw xmm8,xmm0
        punpcklbw xmm9,xmm0
        
        ;salvamos las esquinas para la cuenta Gy
        movdqu xmm10,xmm1
        movdqu xmm11,xmm3
        movdqu xmm12,xmm7
        movdqu xmm13,xmm9

        ;cuenta Gx:
        movdqu xmm14,xmm0 ;acumulador Gx

        psllw xmm4,1
        psllw xmm6,1

        paddw xmm14,xmm9
        paddw xmm14,xmm6
        paddw xmm14,xmm3
        psubw xmm14,xmm1
        psubw xmm14,xmm4
        psubw xmm14,xmm7

        pabsw xmm14,xmm14

        ;cuenta Gy:
        movdqu xmm15,xmm0 ;acumulador Gy

        psllw xmm2,1
        psllw xmm8,1

        paddw xmm15,xmm12
        paddw xmm15,xmm8
        paddw xmm15,xmm13
        psubw xmm15,xmm10
        psubw xmm15,xmm2
        psubw xmm15,xmm11

        pabsw xmm15,xmm15

        ;suma saturada
        paddusw xmm14,xmm15 ;se guarda en xmm14
        packuswb xmm14,xmm0

        movq [rsi],xmm14

    .casosBorde:
    mov r14,rdx ;rdx = columnas y rcx = filas
    mov r15,rcx ;r15 = iteraciones sobre las columnas + 1

    movq xmm0,[blanco]

    .primeraFila:

        ;movq xmm0,[blanco] lo pongo afuera del loop
        movq [r13],xmm0

        cmp r14,8
        je .ultimaCol

        add r13,8
        sub r14,8

        jmp .primeraFila


    .ultimaCol:
        cmp r15,1
        je .ultimaFila

        mov byte[r13 + 7],255

        dec r15
        add r13,rdx
        jmp .ultimaCol


    .ultimaFila:
        ; movq xmm0,[blanco] lo puse fuera del loop
        movq [r13],xmm0

        cmp r14,rdx
        je .primeraCol

        sub r13,8
        add r14,8
        jmp .ultimaFila

    .primeraCol:
        cmp r15,rcx
        je .fin

        mov byte[r13],255

        inc r15
        sub r13,rdx
        jmp .primeraCol


    .fin:

        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp
        ret 