.intel_syntax noprefix

.extern malloc
.extern free
.extern getint
.extern putint

.global unionfind

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
    sub rsp, 8
    push rbx
    push r14
    push r15

    // dynamically allocate memory for data structure.
    // `rsi` and `rdx` may be affected during malloc and are thus preserved
    // and then released after the memory allocation.
    push rsi
    push rdx
    push rdi
    sub rsp, 8
    call malloc // reserve `set_size` bytes for group
    mov r14, rax // r14: group G_i
    add rsp, 8
    pop rdi
    call malloc // reserve `set_size` bytes for group size
    mov r15, rax // r15: group size |G_i|
    pop rdx
    pop rsi

    // parse command to function
    .Lparse_cmd:
        cmp byte ptr [rsi], 0x46
        je .Lfind
        cmp byte ptr [rsi], 0x55
        je .Lunion
        jmp .Lfinish
    
    // find
    .Lfind:
        // load parameters
        lea rdi, [rsi + 1]
        call getint
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
        mov rsi, rdi
        lea rdi, [rsi + 1]
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
        add rsp, 8
        // reset base pointer
        pop rbp

    // exit program 
    ret
    // :) DONE!

