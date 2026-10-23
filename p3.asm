section .data
    ; Operation is modified here
    operation dd 1

    msg_balanced db "0 bytes (Balanced)", 10
    msg_len equ $ - msg_balanced

section .text
    global _start

_start:
    ; initial states are modified here
    mov eax, 10
    mov ebx, 20
    mov ecx, 30
    mov edx, 40

    mov esi, esp

    call calculate_foo

    cmp esp, esi
    jne .stack_error

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_balanced
    mov edx, msg_len
    int 0x80
    jmp .exit

.stack_error:
    mov eax, 1
    mov ebx, 1
    int 0x80

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

calculate_foo:
    push eax
    push ebx
    push ecx
    push edx

    mov eax, [operation]

    cmp eax, 1
    je .multiply_add

    cmp eax, 2
    je .divide_accumulate

    cmp eax, 3
    je .subtract_scale

    cmp eax, 4
    je .bitwise

    cmp eax, 5
    je .modulo_divide

    cmp eax, 6
    je .zero_arithmetic

    jmp .restore

.multiply_add:
    imul eax, ebx
    add eax, ecx
    add eax, edx
    jmp .restore

.divide_accumulate:
    xor edx, edx
    div ebx
    add eax, ecx
    jmp .restore

.subtract_scale:
    sub eax, ebx
    imul eax, ecx
    sub eax, edx
    jmp .restore

.bitwise:
    and eax, ebx
    or ecx, edx
    xor eax, ecx
    jmp .restore

.modulo_divide:
    xor edx, edx
    div ecx

    mov eax, edx
    xor edx, edx
    div ebx
    jmp .restore

.zero_arithmetic:
    add eax, edx
    sub ebx, ecx
    xor ecx, eax
    or edx, eax

.restore:
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    ret