.intel_syntax noprefix

.extern malloc
.extern free
.extern getint
.extern putint

.global unionfind

.section .rodata
.align 16

.section .text
/**
 *
 * ------------------------
 * FUNCTION ARGUMENT GUIDE:
 * ------------------------
 * rdi: uint64_t set_size
 * rsi: char* instruction_string
 * rdx: char* solution_string
 *
 * ----------------
 * CONSTANTS GUIDE:
 * ----------------
 * ASCII F: 0x46
 * ASCII U: 0x55
 * ASCII &: 0x26
 *
 */
unionfind:
    // setup base pointer
    push rbp
    mov rbp, rsp

    // preserve registers
    sub rsp, 0x8
    push rbx
    push r14
    push r15

    // dynamically allocate memory for data structure.
    // `rsi` and `rdx` may be affected during malloc and are thus preserved
    // and then released after the memory allocation.
    push rsi
    push rdx
    push rdi
    mov rbx, rdi // bx: set_size
    shl rdi, 0x1 // n ∈ [0, 65535] requires 2 bytes for representation
    sub rsp, 0x8
    call malloc // reserve memory for group G_i
    mov r14, rax // r14: group G_i
    add rsp, 0x8
    pop rdi
    call malloc // reserve memory for group size |G_i|
    mov r15, rax // r15: group size |G_i|
    pop rdx
    pop rsi

    // initialize data structure values
    .LDSinitialize:
        dec rbx
        mov word ptr [r14 + rbx * 2], bx
        mov word ptr [r15 + rbx * 2], 0x1
        test rbx, rbx
        jnz .LDSinitialize

    // parse command to function
    .Lparse_cmd:
        cmp byte ptr [rsi], 0x46
        je .Lfind
        cmp byte ptr [rsi], 0x55
        je .Lunion
        jmp .Lfinish
    
    // find
    .Lfind:
        mov word ptr [rdx], 0x46
        inc rdx
        push rdx
        // load parameters
        lea rdi, [rsi + 1]
        call getint
        pop rdx
        mov rcx, rax // rcx: data point D_i
        mov rsi, rdi
        // ...
        jmp .Lparse_cmd
    
    // union
    .Lunion:
        // load parameters
        lea rdi, [rsi + 1]
        call getint
        mov rbx, rax // rbx: first data point D_i
        inc rdi
        call getint
        mov rcx, rax // rcx: second data point D_j
        mov rsi, rdi
        // ...
        jmp .Lparse_cmd
    
    // cleanup program
    .Lfinish:
        // free dynamically allocated memory
        mov rdi, r15
        call free
        mov rdi, r14
        call free
        // release preserved registers
        pop r15
        pop r14
        pop rbx
        add rsp, 0x8
        // reset base pointer
        pop rbp

    // exit program 
    ret
    // :) DONE!

