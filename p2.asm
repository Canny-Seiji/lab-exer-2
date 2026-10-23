section .data
    expression db "A + (B * (C - D)", 0

    msg_balanced   db "1 (Balanced)", 10
    len_balanced   equ $ - msg_balanced

    msg_extra      db "0 (Unbalanced - Extra opening)", 10
    len_extra      equ $ - msg_extra

    msg_unexpected db "0 (Unbalanced - Unexpected closing)", 10
    len_unexpected equ $ - msg_unexpected

    msg_wrong      db "0 (Unbalanced - Wrong order)", 10
    len_wrong      equ $ - msg_wrong

    msg_unclosed   db "0 (Unbalanced - Unclosed)", 10
    len_unclosed   equ $ - msg_unclosed

section .text
    global _start

_start:
    mov esi, expression
    call check_parentheses

    cmp eax, 1
    je .balanced

    cmp ebx, 1
    je .extra
    cmp ebx, 2
    je .unexpected
    cmp ebx, 3
    je .wrong
    jmp .unclosed

.balanced:
    mov ecx, msg_balanced
    mov edx, len_balanced
    jmp .print

.extra:
    mov ecx, msg_extra
    mov edx, len_extra
    jmp .print

.unexpected:
    mov ecx, msg_unexpected
    mov edx, len_unexpected
    jmp .print

.wrong:
    mov ecx, msg_wrong
    mov edx, len_wrong
    jmp .print

.unclosed:
    mov ecx, msg_unclosed
    mov edx, len_unclosed

.print:
    mov eax, 4
    mov ebx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

check_parentheses:
    xor ecx, ecx             
    xor ebp, ebp             
    xor edi, edi             

.scan:
    mov al, [esi]
    test al, al
    jz .finish

    cmp al, ' '
    je .advance
    cmp al, 9
    je .advance

    test ebp, ebp
    jnz .check_char

    mov ebp, 1
    cmp al, ')'
    je .wrong_order

    cmp al, '('
    jne .check_char

    mov edi, 1

.check_char:
    cmp al, '('
    je .open

    cmp al, ')'
    je .close

    jmp .advance

.open:
    movzx eax, byte [esi]
    push eax
    inc ecx
    jmp .advance

.close:
    test ecx, ecx
    jz .unexpected

    pop eax
    dec ecx
    jmp .advance

.advance:
    inc esi
    jmp .scan

.unexpected:
    mov ebx, 2
    jmp .fail

.wrong_order:
    mov ebx, 3
    jmp .fail

.finish:
    test ecx, ecx
    jz .success

    test edi, edi
    jnz .extra_opening

    mov ebx, 4
    jmp .fail

.extra_opening:
    mov ebx, 1
    jmp .fail

.success:
    mov eax, 1
    xor ebx, ebx
    ret

.fail:
    lea esp, [esp + ecx * 4]
    xor eax, eax
    ret