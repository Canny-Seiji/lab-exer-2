section .data
    prompt db "Enter 5 integers separated by spaces: "
    prompt_len equ $ - prompt

    array_msg db "Reversed array: "
    array_msg_len equ $ - array_msg

    sum_msg db 10, "Sum: "
    sum_msg_len equ $ - sum_msg

    newline db 10

section .bss
    source      resd 5
    destination resd 5
    sum         resd 1
    input_buf   resb 128
    number_buf  resb 12

section .text
    global _start

_start:
    ; Display input prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    ; Read a line of input
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 127
    int 0x80

    test eax, eax
    jle exit_program
    mov byte [input_buf + eax], 0

    mov esi, input_buf
    mov edi, source
    mov ecx, 5

read_array:
    call parse_integer
    mov [edi], eax
    add edi, 4
    loop read_array

    mov esi, source
    mov ecx, 5

push_loop:
    push dword [esi]
    add esi, 4
    loop push_loop

    mov edi, destination
    mov ecx, 5
    xor eax, eax

pop_loop:
    pop edx
    mov [edi], edx
    add eax, edx
    add edi, 4
    loop pop_loop

    mov [sum], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, array_msg
    mov edx, array_msg_len
    int 0x80

    mov esi, destination
    mov ecx, 5

print_array:
    mov eax, [esi]
    call print_integer
    add esi, 4
    loop print_array

    mov eax, 4
    mov ebx, 1
    mov ecx, sum_msg
    mov edx, sum_msg_len
    int 0x80

    mov eax, [sum]
    call print_integer

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80

parse_integer:
    xor eax, eax
    xor ebx, ebx

.skip_whitespace:
    mov dl, [esi]
    cmp dl, ' '
    je .skip
    cmp dl, 9
    je .skip
    cmp dl, 10
    je .skip
    cmp dl, 13
    je .skip
    jmp .check_sign

.skip:
    inc esi
    jmp .skip_whitespace

.check_sign:
    cmp byte [esi], '-'
    jne .check_plus
    mov ebx, 1
    inc esi
    jmp .digits

.check_plus:
    cmp byte [esi], '+'
    jne .digits
    inc esi

.digits:
    movzx edx, byte [esi]
    sub edx, '0'
    cmp edx, 9
    ja .done

    imul eax, eax, 10
    add eax, edx
    inc esi
    jmp .digits

.done:
    test ebx, ebx
    jz .return
    neg eax

.return:
    ret

print_integer:
    pushad

    mov edi, number_buf + 11
    mov byte [edi], ' '
    mov ecx, 1
    mov ebx, 10
    xor ebp, ebp

    test eax, eax
    jns .digits
    mov ebp, 1
    neg eax

.digits:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx

    test eax, eax
    jnz .digits

    test ebp, ebp
    jz .write
    dec edi
    mov byte [edi], '-'
    inc ecx

.write:
    mov edx, ecx
    mov ecx, edi
    mov ebx, 1
    mov eax, 4
    int 0x80

    popad
    ret