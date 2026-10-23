section .data
    prompt db "Enter decimal number (0-65535): "
    prompt_len equ $ - prompt

section .bss
    input_buffer  resb 16
    output_buffer resb 17

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 16
    int 0x80

    test eax, eax
    jle exit_program

    mov ecx, eax
    mov esi, input_buffer
    xor eax, eax

parse_decimal:
    movzx edx, byte [esi]
    cmp dl, 10
    je convert_binary
    cmp dl, 13
    je convert_binary

    sub edx, '0'
    imul eax, eax, 10
    add eax, edx

    inc esi
    loop parse_decimal

convert_binary:
    mov ebx, 2
    xor ecx, ecx

divide_loop:
    xor edx, edx
    div ebx
    push edx
    inc ecx

    test eax, eax
    jnz divide_loop

    mov edi, output_buffer

build_output:
    pop edx
    add dl, '0'
    mov [edi], dl
    inc edi
    loop build_output

    mov byte [edi], 10
    inc edi

    mov edx, edi
    sub edx, output_buffer
    mov eax, 4
    mov ebx, 1
    mov ecx, output_buffer
    int 0x80

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80