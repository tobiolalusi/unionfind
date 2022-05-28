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
 * ASCII L: 0x4C
 * ASCII &: 0x26
 *
 */
unionfind:
    // setup base pointer
    push rbp
    mov rbp, rsp

    // preserve registers
    push rbx
    push r13
    push r14
    push r15

    // dynamically allocate memory for data structure.
    // `rsi` and `rdx` may be affected during malloc and are thus preserved
    // and then released after the memory allocation.
    push rsi
    push rdx
    mov rbx, rdi // rbx: `set_size`
    shl rdi, 0x2 // both data structure, n ∈ [0, 65535] require 2 bytes for representation
    call malloc // reserve memory for data structures
    mov r14, rax // r14: pointer to group G_i
    mov r15, rbx
    shl r15, 0x1
    add r15, r14 // r15: pointer to group size |G_i|
    pop rdx
    pop rsi

    // initialize data structure values
    .LDSinit:
        dec rbx
        mov word ptr [r14 + rbx * 2], bx
        mov word ptr [r15 + rbx * 2], 0x1
        test rbx, rbx
        jnz .LDSinit

    // parse command to function
    .Lparse_cmd:
        cmp byte ptr [rsi], 0x46
        je .Lfind
        cmp byte ptr [rsi], 0x55
        je .Lunion
        jmp .Lfinish
    
    // find
    .Lfind:
        mov word ptr [rdx], 0x46 // write 'F' to `solution_string`
        inc rdx
        push rdx // pointer to next `solution_string` char
        sub rsp, 0x8
        // load parameters
        lea rdi, [rsi + 1]
        call getint // `rdi` safe
        add rsp, 0x8
        pop rdx
        mov rcx, rax // rcx: data point D_i
        push rdi // pointer to next `insruction_string` char
        sub rsp, 0x8
        mov r13, 0x0 // r13: traversed levels
        xor rdi, rdi // reset `rdi`
        .Lfind_loop:
            mov di, word ptr [r14 + rcx * 2] // rdi: D_i's tentative group G_i
            test di, cx
            jz .Lfind_loop_end
        .Lfind_loop_end:
            // write group G_i to `solution_string`
            mov rsi, rdx
            call putint
            mov rdx, rax
            // write traversed levels to `solution_string`
            mov word ptr [rdx], 0x4c
            inc rdx
            mov rdi, r13
            mov rsi, rdx
            call putint
            mov rdx, rax
        add rsp, 0x8
        pop rsi
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
        mov rdi, r14
        call free
        // release preserved registers
        pop r15
        pop r14
        pop r13
        pop rbx
        // reset base pointer
        pop rbp

    // exit program 
    ret
    // :) DONE!

