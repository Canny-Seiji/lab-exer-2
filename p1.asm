section .data
    original db "Hello", 0
    str_len  equ $ - original - 1
    reversed times str_len + 1 db 0
    newline  db 10

section .text
    global _start

_start:
    mov esi, original
    mov ecx, str_len

push_chars:
    test ecx, ecx
    jz reverse_chars

    movzx eax, byte [esi] 
    push eax              
    inc esi
    dec ecx
    jmp push_chars

reverse_chars:
    mov edi, reversed
    mov ecx, str_len

pop_chars:
    test ecx, ecx
    jz output_string

    pop eax
    mov [edi], al        
    inc edi
    dec ecx
    jmp pop_chars

output_string:
    mov byte [edi], 0

    mov eax, 4
    mov ebx, 1
    mov ecx, reversed
    mov edx, str_len
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80