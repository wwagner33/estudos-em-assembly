section .data
    hello_message db 'Hello, Assembly!', 10  ; Mensagem a ser impressa
    hello_len equ $-hello_message            ; Comprimento da mensagem

section .bss
    buffer resb 1  ; Buffer para armazenar uma entrada do usuário

section .text
    global _start

_start:
    ; Escrever a mensagem "Hello, Assembly!" na tela
    mov rax, 1                  ; syscall: sys_write
    mov rdi, 1                  ; arquivo: stdout
    mov rsi, hello_message      ; mensagem a ser escrita
    mov rdx, hello_len          ; comprimento da mensagem
    syscall                     ; chama o kernel

    ; Ler uma entrada do usuário (esperar por uma tecla)
    mov rax, 0                  ; syscall: sys_read
    mov rdi, 0                  ; arquivo: stdin
    mov rsi, buffer             ; onde armazenar a entrada
    mov rdx, 1                  ; número de bytes para ler
    syscall                     ; chama o kernel

    ; Sair do programa
    mov rax, 60                 ; syscall: sys_exit
    xor rdi, rdi                ; código de saída: 0
    syscall                     ; chama o kernel
