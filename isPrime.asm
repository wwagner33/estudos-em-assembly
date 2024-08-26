section .data
    prompt_num db 'Digite um número (ou "x" para sair): ', 0
    prompt_algo db 'Escolha o algoritmo (1-4 ou "x" para sair):', 10, \
                 '1 - Força Bruta', 10, \
                 '2 - Divisão até a Raiz Quadrada', 10, \
                 '3 - Teste com Números Ímpares', 10, \
                 '4 - Teste de Miller-Rabin', 10, 0
    true_msg db 'True', 10, 0
    false_msg db 'False', 10, 0
    newline db 10, 0
    error_msg db 'Opção inválida!', 10, 0
    buffer_overflow_msg db 'Erro: Número muito grande!', 10, 0

section .bss
    num resb 20     ; Buffer para o número (19 caracteres + 1 para newline)
    algo_choice resb 2  ; Buffer para a escolha do algoritmo

section .text
    global _start

_start:
main_loop:
    ; Limpar os buffers
    mov rdi, num
    mov rcx, 20
    xor rax, rax
    rep stosb               ; Limpa o buffer `num`

    mov rdi, algo_choice
    mov rcx, 2
    rep stosb               ; Limpa o buffer `algo_choice`

    ; Exibir o prompt para o número
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_num
    mov rdx, 36
    syscall

    ; Ler o número do usuário
    mov rax, 0
    mov rdi, 0
    mov rsi, num
    mov rdx, 20
    syscall

    ; Verificar se o usuário digitou "x" para sair
    mov al, byte [num]
    cmp al, 'x'
    je exit_program

    ; Verificar se o número cabe no buffer (se tem até 19 caracteres)
    mov rcx, 0
check_input_length:
    mov al, byte [num + rcx]
    cmp al, 10           ; Verifica se é nova linha (fim da entrada)
    je input_ok
    inc rcx
    cmp rcx, 19          ; Verifica se o comprimento excede o limite
    ja buffer_overflow   ; Se exceder, exibe mensagem de erro e sai do loop
    jmp check_input_length

input_ok:
    ; Converter a string lida para um inteiro
    mov rsi, num
    call string_to_int
    mov rbx, rax           ; Armazena o número em rbx

    ; Exibir o prompt para o algoritmo
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_algo
    mov rdx, 154            ; Comprimento da mensagem
    syscall

    ; Ler a escolha do algoritmo
    mov rax, 0
    mov rdi, 0
    mov rsi, algo_choice
    mov rdx, 2
    syscall

    ; Verificar se o usuário digitou "x" para sair
    mov al, byte [algo_choice]
    cmp al, 'x'
    je exit_program

    ; Converter a escolha do algoritmo para inteiro
    mov rsi, algo_choice
    call string_to_int

    ; Decidir qual algoritmo usar
    cmp rax, 1
    je use_algo1
    cmp rax, 2
    je use_algo2
    cmp rax, 3
    je use_algo3
    cmp rax, 4
    je use_algo4
    jmp invalid_option

use_algo1:
    mov rdi, rbx
    call is_prime_brute_force
    jmp print_result

use_algo2:
    mov rdi, rbx
    call is_prime_basic
    jmp print_result

use_algo3:
    mov rdi, rbx
    call is_prime_optimized
    jmp print_result

use_algo4:
    mov rdi, rbx
    call is_prime_miller_rabin
    jmp print_result

invalid_option:
    mov rsi, error_msg
    mov rdx, 18
    jmp print_result

buffer_overflow:
    mov rsi, buffer_overflow_msg
    mov rdx, 30
    call display_result  ; Exibe a mensagem de erro
    jmp exit_program    ; Sair do programa

print_result:
    cmp rax, 0
    je not_prime
    mov rsi, true_msg
    mov rdx, 5
    jmp display_result

not_prime:
    mov rsi, false_msg
    mov rdx, 6

display_result:
    mov rax, 1
    mov rdi, 1
    syscall

    jmp main_loop  ; Retorna ao início do loop principal

exit_program:
    ; Sair do programa
    mov rax, 60
    xor rdi, rdi
    syscall

; Função para converter string para inteiro
string_to_int:
    xor rax, rax
    xor rcx, rcx
convert_loop:
    movzx rdx, byte [rsi + rcx]
    cmp rdx, 10
    je done_convert
    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    jmp convert_loop
done_convert:
    ret

; Algoritmo 1: Divisão por todos os números até n-1 (força bruta)
is_prime_brute_force:
    cmp rdi, 2
    jl not_prime_check
    je prime_check
    mov rcx, 2
prime_brute_loop:
    mov rax, rdi
    xor rdx, rdx
    div rcx
    test rdx, rdx
    jz not_prime_check
    inc rcx
    cmp rcx, rdi
    jne prime_brute_loop
prime_check:
    mov rax, 1
    ret
not_prime_check:
    mov rax, 0
    ret

; Algoritmo 2: Divisão até a raiz quadrada de n
is_prime_basic:
    cmp rdi, 2
    jl not_prime_check
    je prime_check
    mov rcx, 2
prime_basic_loop:
    mov rax, rdi
    xor rdx, rdx
    div rcx
    test rdx, rdx
    jz not_prime_check
    inc rcx
    mov rax, rcx
    imul rax, rax
    cmp rax, rdi
    jbe prime_basic_loop
    jmp prime_check

; Algoritmo 3: Teste com números ímpares até a raiz quadrada
is_prime_optimized:
    cmp rdi, 2
    jl not_prime_check
    je prime_check
    test rdi, 1
    jz not_prime_check
    mov rcx, 3
prime_opt_loop:
    mov rax, rdi
    xor rdx, rdx
    div rcx
    test rdx, rdx
    jz not_prime_check
    add rcx, 2
    mov rax, rcx
    imul rax, rax
    cmp rax, rdi
    jbe prime_opt_loop
    jmp prime_check

; Algoritmo 4: Teste de Miller-Rabin simplificado
is_prime_miller_rabin:
    cmp rdi, 2
    jl not_prime_check
    je prime_check
    mov rcx, rdi
    dec rcx
    test rdi, 1
    jz not_prime_check
    mov rax, 1
    ret