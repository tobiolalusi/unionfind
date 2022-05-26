.intel_syntax noprefix

.global getint

.section .text
// rdi: char* str
getint:
    push rbp
    mov rbp, rsp
    push rbx
    xor rbx, rbx
    xor rax, rax
    mov rcx, 0xa

    .Lloop:
        mov bl, byte ptr [rdi]
        cmp rbx, 0x30
        jl .Lfinish
        cmp rbx, 0x39
        jg .Lfinish
        mul rcx
        sub rbx, 0x30
        add rax, rbx
        inc rdi
        jmp .Lloop
    
    .Lfinish:
    pop rbx
    pop rbp
    ret
